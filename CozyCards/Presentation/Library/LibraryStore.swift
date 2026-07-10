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

    /// Selected tag filters. Empty means "any tag", which is what a card saved
    /// straight from chat has - it is tagless and must stay visible.
    var tags: Set<String> = []


    private let repository: LibraryRepository


    init(repository: LibraryRepository) {
        self.repository = repository
        observe()
    }


    /// Every tag in use, sorted, for the filter chips. Derived rather than
    /// stored: tags are a view onto the items, not a separate collection, which
    /// is the whole reason the dictionary entity is gone.
    var allTags: [String] {
        Set(items.flatMap(\.tags)).sorted()
    }


    /// Items after applying the current `query`, `kinds` and `tags` filters.
    ///
    /// Selected tags combine as AND: picking two chips asks for the cards that
    /// carry both, the way people narrow a search rather than widen it.
    var filtered: [LibraryItem] {
        items.filter { item in
            item.matches(query)
                && (kinds.isEmpty || kinds.contains(item.card.kind))
                && tags.isSubset(of: item.tags)
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
