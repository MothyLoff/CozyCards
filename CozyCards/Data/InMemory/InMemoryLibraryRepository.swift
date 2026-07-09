import Foundation



/// In-memory `LibraryRepository`, used until a disk-backed implementation
/// replaces it behind the same protocol. All state is isolated on the actor.
actor InMemoryLibraryRepository: LibraryRepository {


    private var items: [LibraryItem]

    private var subscribers: [UUID: AsyncStream<[LibraryItem]>.Continuation] = [:]


    init(items: [LibraryItem] = []) {
        self.items = items
    }


    func all() -> [LibraryItem] {
        items
    }

    func add(_ item: LibraryItem) {
        items.append(item)
        broadcast()
    }

    func update(_ item: LibraryItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index] = item
        broadcast()
    }

    func remove(id: UUID) {
        items.removeAll { $0.id == id }
        broadcast()
    }

    func search(query: String, kinds: Set<CardKind>) -> [LibraryItem] {
        items.filter { item in
            (kinds.isEmpty || kinds.contains(item.card.kind)) && item.matches(query)
        }
    }

    func observe() -> AsyncStream<[LibraryItem]> {
        AsyncStream { continuation in
            let id = UUID()
            subscribers[id] = continuation
            continuation.yield(items)
            continuation.onTermination = { [weak self] _ in
                Task { await self?.cancelSubscription(id) }
            }
        }
    }


    private func cancelSubscription(_ id: UUID) {
        subscribers[id] = nil
    }

    private func broadcast() {
        let snapshot = items
        for continuation in subscribers.values {
            continuation.yield(snapshot)
        }
    }


}
