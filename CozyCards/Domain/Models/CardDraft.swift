import Foundation
import Observation



/// A card the model produced inside a chat turn.
///
/// A draft has an identity of its own because its life does not match the life
/// of the message it appeared in: it is saved to the library, and the user may
/// then edit or discard it. One turn can hold several drafts.
///
/// A draft never streams, and `card` is never absent. A card is the *arguments*
/// of a tool call, and the framework hands a tool its arguments whole - it does
/// not surface them half-generated. So by the time a draft exists its card is
/// finished and already in the library, and `state` records only whether the
/// user took that save back.
@Observable
final class CardDraft: Identifiable {


    let id: UUID

    let card: Card

    /// The library item this draft was saved as. `nil` once discarded.
    var libraryItemID: UUID?

    var state: State


    init(
        id: UUID = UUID(),
        card: Card,
        libraryItemID: UUID? = nil,
        state: State = .saved
    ) {
        self.id = id
        self.card = card
        self.libraryItemID = libraryItemID
        self.state = state
    }


    /// `.discarded` is the user undoing the automatic save: the draft stays in
    /// the transcript, the library item does not.
    enum State: Equatable {


        case saved

        case discarded


    }


}
