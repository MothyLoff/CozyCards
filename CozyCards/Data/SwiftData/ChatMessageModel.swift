import Foundation
import SwiftData



/// On-disk row for one `ChatMessage`.
///
/// Persists the turn's free text and the cards it produced. `Card` is `Codable`
/// and stored whole, as one JSON blob per message, for the same reason
/// `LibraryItemModel` stores it that way: flattening a five-case union into
/// columns buys nothing and breaks on the first new case.
///
/// A card the user kept also survives on its own, as a `LibraryItemModel`. The
/// draft here is the transcript's copy - it remembers that this turn produced
/// this card, and whether the user took the save back.
@Model
final class ChatMessageModel {


    @Attribute(.unique) var id: UUID
    var prompt: String
    var createdAt: Date

    var text: String

    var stateKind: String    // "streaming" | "completed" | "failed"
    var failureReason: String?

    /// `[CardDraftRecord]`, JSON-encoded. `nil` for a turn that produced none.
    @Attribute(.externalStorage) var cardsData: Data?

    var thread: ChatThreadModel?


    init(message: ChatMessage) {
        id = message.id
        prompt = message.prompt
        createdAt = .now
        text = ""
        stateKind = "streaming"
        failureReason = nil
        cardsData = nil

        apply(message: message)
    }


    func apply(message: ChatMessage) {
        text = message.text

        switch message.state {
        case .streaming:
            stateKind = "streaming"
            failureReason = nil
        case .completed:
            stateKind = "completed"
            failureReason = nil
        case .failed(let reason):
            stateKind = "failed"
            failureReason = reason
        }

        let records = message.cards.map(CardDraftRecord.init)
        cardsData = records.isEmpty ? nil : try? JSONEncoder().encode(records)
    }


    func toDomain() -> ChatMessage {
        let state: ChatMessage.State
        switch stateKind {
        case "completed": state = .completed
        case "failed": state = .failed(failureReason ?? "Something went wrong")
        default: state = .streaming
        }

        return ChatMessage(
            id: id,
            prompt: prompt,
            text: text,
            cards: decodedDrafts(),
            state: state
        )
    }


    /// A row written before cards were persisted decodes as no cards, not as a
    /// crash: an unreadable blob is an empty turn, and the library still holds
    /// whatever the user saved.
    private func decodedDrafts() -> [CardDraft] {
        guard let cardsData,
              let records = try? JSONDecoder().decode([CardDraftRecord].self, from: cardsData)
        else { return [] }

        return records.map { $0.toDomain() }
    }


}



/// The storable part of a `CardDraft`.
///
/// `CardDraft.State` stays out of the storage format on purpose: it is two
/// cases today, and a raw value written to disk would freeze them. What a row
/// records is the card, its link to the library, and one flag for whether the
/// user took the save back.
private struct CardDraftRecord: Codable {


    let id: UUID
    let card: Card
    let libraryItemID: UUID?
    let isDiscarded: Bool


    init(_ draft: CardDraft) {
        id = draft.id
        card = draft.card
        libraryItemID = draft.libraryItemID
        isDiscarded = draft.state == .discarded
    }


    func toDomain() -> CardDraft {
        CardDraft(
            id: id,
            card: card,
            libraryItemID: libraryItemID,
            state: isDiscarded ? .discarded : .saved
        )
    }


}
