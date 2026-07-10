import Foundation
import SwiftData



/// On-disk row for a saved card.
///
/// The card is stored whole, as a `.codable` attribute, rather than flattened
/// into columns: `Card` is a five-case sum type, and a flat row could carry
/// fields belonging to a case it is not in. The cost is that a codable
/// attribute is opaque to SwiftData - it cannot appear in a `#Predicate` or a
/// `SortDescriptor` - so the two things queries actually need, `kindRaw` and
/// `primaryText`, are denormalized beside it and kept in sync by `apply(_:)`.
///
/// `.codable` does not track migrations. The encoding of `Card` is a storage
/// contract: renaming a case or a field silently breaks decoding of rows
/// already on disk.
@Model
final class LibraryItemModel {


    @Attribute(.unique) var id: UUID

    @Attribute(.codable) var card: Card

    /// `card.kind.rawValue`, denormalized: `card` is opaque to predicates.
    var kindRaw: String

    /// `card.primaryText`, denormalized for search and sorting.
    var primaryText: String

    var tags: [String]
    var createdAt: Date
    var sourceMessageID: UUID?


    init(item: LibraryItem) {
        id = item.id
        card = item.card
        kindRaw = item.card.kind.rawValue
        primaryText = item.card.primaryText
        tags = item.tags
        createdAt = item.createdAt
        sourceMessageID = item.sourceMessageID
    }


    /// Replaces everything a user or a re-save can change. `id` and `createdAt`
    /// are identity, not content, and stay put.
    func apply(_ item: LibraryItem) {
        card = item.card
        kindRaw = item.card.kind.rawValue
        primaryText = item.card.primaryText
        tags = item.tags
        sourceMessageID = item.sourceMessageID
    }


    func toDomain() -> LibraryItem {
        LibraryItem(
            id: id,
            card: card,
            tags: tags,
            createdAt: createdAt,
            sourceMessageID: sourceMessageID
        )
    }


}
