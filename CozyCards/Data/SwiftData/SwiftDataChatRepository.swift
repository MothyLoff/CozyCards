import Foundation
import SwiftData



/// Storage for a thread's raw model `Transcript`, kept separate from
/// `ChatRepository` since transcripts are an implementation detail of how
/// context gets restored, not part of the `ChatThread`/`ChatMessage`
/// domain model.
protocol ChatTranscriptStoring: Sendable {

    func loadTranscript(for threadID: UUID) async -> Data?
    func saveTranscript(_ data: Data, for threadID: UUID) async

}



/// Disk-backed `ChatRepository`, built on SwiftData.
///
/// Runs on the main actor rather than a background `@ModelActor`, unlike
/// `SwiftDataLibraryRepository`. `ChatThread`/`ChatMessage` are plain
/// `@Observable` classes (not `Sendable`), and under this project's default
/// actor isolation (`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`) that makes
/// them MainActor-only — so constructing them has to happen here.
/// `@unchecked Sendable` reflects that every access is already serialized
/// by `@MainActor`.
@MainActor
final class SwiftDataChatRepository: ChatRepository, ChatTranscriptStoring, @unchecked Sendable {


    private let modelContext: ModelContext
    private var subscribers: [UUID: AsyncStream<[ChatThread]>.Continuation] = [:]


    init(modelContainer: ModelContainer) {
        modelContext = modelContainer.mainContext
    }


    func threads() -> [ChatThread] {
        let descriptor = FetchDescriptor<ChatThreadModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let rows = (try? modelContext.fetch(descriptor)) ?? []
        return rows.map { $0.toDomain() }
    }

    func add(_ thread: ChatThread) {
        modelContext.insert(ChatThreadModel(thread: thread))
        save()
        broadcast()
    }

    /// Replaces a persisted thread's title and messages wholesale. `ChatThread`
    /// is a reference type mutated in place upstream, so this is the only
    /// point where the mutations actually get written to disk.
    func save(_ thread: ChatThread) {
        guard let row = fetchRow(id: thread.id) else {
            add(thread)
            return
        }

        row.title = thread.title
        for existingMessage in row.messages {
            modelContext.delete(existingMessage)
        }
        row.messages = thread.messages.map { ChatMessageModel(message: $0) }

        save()
        broadcast()
    }

    func rename(id: UUID, to title: String) {
        guard let row = fetchRow(id: id) else { return }
        row.title = title
        save()
        broadcast()
    }

    func remove(id: UUID) {
        guard let row = fetchRow(id: id) else { return }
        modelContext.delete(row)
        save()
        broadcast()
    }

    func observe() -> AsyncStream<[ChatThread]> {
        let snapshot = threads()
        return AsyncStream { continuation in
            let subscriptionID = UUID()
            subscribers[subscriptionID] = continuation
            continuation.yield(snapshot)
            continuation.onTermination = { [weak self] _ in
                Task { @MainActor in self?.cancelSubscription(subscriptionID) }
            }
        }
    }

    func loadTranscript(for threadID: UUID) -> Data? {
        fetchRow(id: threadID)?.transcriptData
    }

    func saveTranscript(_ data: Data, for threadID: UUID) {
        guard let row = fetchRow(id: threadID) else { return }
        row.transcriptData = data
        save()
    }


    private func cancelSubscription(_ id: UUID) {
        subscribers[id] = nil
    }

    private func broadcast() {
        let snapshot = threads()
        for continuation in subscribers.values {
            continuation.yield(snapshot)
        }
    }

    private func fetchRow(id: UUID) -> ChatThreadModel? {
        var descriptor = FetchDescriptor<ChatThreadModel>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return (try? modelContext.fetch(descriptor))?.first
    }

    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("SwiftDataChatRepository save failed:", error)
        }
    }


}
