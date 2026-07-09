import Foundation



/// A card saved to the user's library.
///
/// Wraps a generated `Card` with identity, freeform tags for search, and an
/// optional link back to the chat message it came from. Tags are edited by the
/// user; the model never sets them.
struct LibraryItem: Identifiable, Hashable, Sendable {


    let id: UUID

    var card: Card

    var tags: [String]

    let createdAt: Date

    var sourceMessageID: UUID?


    init(
        id: UUID = UUID(),
        card: Card,
        tags: [String] = [],
        createdAt: Date = .now,
        sourceMessageID: UUID? = nil
    ) {
        self.id = id
        self.card = card
        self.tags = tags
        self.createdAt = createdAt
        self.sourceMessageID = sourceMessageID
    }


}
