import Foundation
import Observation
import FoundationModels



/// A card the model is producing, or has produced, inside a chat turn.
///
/// A draft has an identity of its own because its life does not match the life
/// of the message it appeared in: it streams, it is saved to the library, and
/// the user may then edit or discard it. One turn can hold several drafts.
///
/// While `state` is `.streaming`, read `snapshot`; once it is `.completed`,
/// `card` holds the finished value and `snapshot` stops changing. `card` is the
/// only value that may reach the library - a snapshot has no guarantees.
@Observable
final class CardDraft: Identifiable {


    let id: UUID

    /// The latest incremental snapshot. Every field may still be absent.
    var snapshot: Card.PartiallyGenerated?

    /// The finished card. Non-`nil` exactly when generation completed.
    var card: Card?

    /// The library item this draft was saved as, once it has been saved.
    var libraryItemID: UUID?

    var state: State


    init(
        id: UUID = UUID(),
        snapshot: Card.PartiallyGenerated? = nil,
        card: Card? = nil,
        libraryItemID: UUID? = nil,
        state: State = .streaming
    ) {
        self.id = id
        self.snapshot = snapshot
        self.card = card
        self.libraryItemID = libraryItemID
        self.state = state
    }


    /// Where the card is in its life. `.discarded` is the user undoing the
    /// automatic save; the draft stays in the transcript, the library item does not.
    enum State: Equatable {


        case streaming

        case completed

        case failed(String)

        case discarded


    }


}
