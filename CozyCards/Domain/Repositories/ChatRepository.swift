import Foundation



/// Storage for chat threads and their messages.
///
/// A `ChatThread` is a reference type, so appending to `thread.messages`
/// mutates it in place; call `save(_:)` to persist changes the implementation
/// cannot observe on its own.
protocol ChatRepository: Sendable {


    func threads() async -> [ChatThread]

    func add(_ thread: ChatThread) async

    func save(_ thread: ChatThread) async

    func rename(id: UUID, to title: String) async

    func remove(id: UUID) async

    /// Emits the full list immediately, then again after every change.
    func observe() async -> AsyncStream<[ChatThread]>


}
