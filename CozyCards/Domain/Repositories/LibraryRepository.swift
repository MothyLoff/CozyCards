import Foundation



/// Storage for saved library items.
///
/// Implementations own persistence (in-memory now, on-disk later). Read once
/// with `all()`, or subscribe to live updates with `observe()`. Every mutation
/// is async so a disk-backed implementation can drop in without changing this
/// contract.
protocol LibraryRepository: Sendable {


    func all() async -> [LibraryItem]

    func add(_ item: LibraryItem) async

    func update(_ item: LibraryItem) async

    func remove(id: UUID) async

    /// Items whose card matches `query`, and, when `kinds` is non-empty, whose
    /// kind is contained in `kinds`. An empty `kinds` set means "any kind".
    func search(query: String, kinds: Set<CardKind>) async -> [LibraryItem]

    /// Emits the full list immediately, then again after every change.
    func observe() async -> AsyncStream<[LibraryItem]>


}
