import Foundation
import SwiftData



/// Disk-backed `LibraryRepository`, built on SwiftData.
///
/// `@ModelActor` gives this its own background `ModelContext` bound to the
/// shared `ModelContainer`, so every method here is already actor-isolated.
/// Every mutating method re-fetches and re-broadcasts a fresh snapshot right
/// after saving, so `observe()` stays correct without depending on
/// SwiftData's own change notifications.
@ModelActor
actor SwiftDataLibraryRepository: LibraryRepository {


    private var subscribers: [UUID: AsyncStream<[LibraryItem]>.Continuation] = [:]


    func all() -> [LibraryItem] {
        let descriptor = FetchDescriptor<LibraryItemModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let rows = (try? modelContext.fetch(descriptor)) ?? []
        return rows.map { $0.toDomain() }
    }

    func add(_ item: LibraryItem) {
        modelContext.insert(LibraryItemModel(item: item))
        save()
        broadcast()
    }

    func update(_ item: LibraryItem) {
        guard let row = fetchRow(id: item.id) else { return }
        row.apply(item)
        save()
        broadcast()
    }

    func remove(id: UUID) {
        guard let row = fetchRow(id: id) else { return }
        modelContext.delete(row)
        save()
        broadcast()
    }

    func search(query: String, kinds: Set<CardKind>) -> [LibraryItem] {
        all().filter { item in
            (kinds.isEmpty || kinds.contains(item.card.kind)) && item.matches(query)
        }
    }

    func observe() -> AsyncStream<[LibraryItem]> {
        let snapshot = all()
        return AsyncStream { continuation in
            let subscriptionID = UUID()
            subscribers[subscriptionID] = continuation
            continuation.yield(snapshot)
            continuation.onTermination = { [weak self] _ in
                Task { await self?.cancelSubscription(subscriptionID) }
            }
        }
    }


    private func cancelSubscription(_ id: UUID) {
        subscribers[id] = nil
    }

    private func broadcast() {
        let snapshot = all()
        for continuation in subscribers.values {
            continuation.yield(snapshot)
        }
    }

    private func fetchRow(id: UUID) -> LibraryItemModel? {
        var descriptor = FetchDescriptor<LibraryItemModel>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return (try? modelContext.fetch(descriptor))?.first
    }

    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("SwiftDataLibraryRepository save failed:", error)
        }
    }


}
