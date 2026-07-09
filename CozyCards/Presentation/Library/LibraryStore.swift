import Foundation
import Observation



/// Screen-facing state for the library. Main views read it from the
/// environment via `@Environment(LibraryStore.self)`.
///
/// Holds the live list and the current filter; mutating intents are forwarded
/// to the repository, and the list is kept in sync through `observe()`.
@Observable
@MainActor
final class LibraryStore {


    private(set) var items: [LibraryItem] = []

    var query: String = ""

    var kinds: Set<CardKind> = []


    private let repository: LibraryRepository


    init(repository: LibraryRepository) {
        self.repository = repository
        observe()
    }


    /// Items after applying the current `query` and `kinds` filter.
    var filtered: [LibraryItem] {
        items.filter { item in
            item.matches(query) && (kinds.isEmpty || kinds.contains(item.card.kind))
        }
    }


    func add(_ item: LibraryItem) {
        Task { await repository.add(item) }
    }

    func remove(id: UUID) {
        Task { await repository.remove(id: id) }
    }

    /// Replaces the tags of an existing item and persists the change.
    func setTags(_ tags: [String], for id: UUID) {
        guard var item = items.first(where: { $0.id == id }) else { return }
        item.tags = tags
        Task { await repository.update(item) }
    }

    /// Persists a full replacement of an existing item (used by the edit form).
    func updateItem(_ item: LibraryItem) {
        Task { await repository.update(item) }
    }


    private func observe() {
        Task { [weak self] in
            guard let stream = await self?.repository.observe() else { return }
            for await snapshot in stream {
                self?.items = snapshot
            }
        }
    }


}
