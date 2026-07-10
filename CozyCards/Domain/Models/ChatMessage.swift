import Foundation
import Observation



/// One turn in a chat: the user's prompt, the model's free-text reply, and any
/// cards the model produced along the way.
///
/// Both `text` and `cards` fill in live while `state` is `.streaming`. A turn
/// can hold text and no cards, cards and no text, or both: the model decides.
/// Each card carries its own lifecycle, so observe the drafts, not this state,
/// to know whether a card is done. UI observes this object directly; there is
/// no need to diff snapshots by hand.
@Observable
final class ChatMessage: Identifiable {


    let id: UUID

    let prompt: String

    var text: String

    var cards: [CardDraft]

    var state: State


    init(
        id: UUID = UUID(),
        prompt: String,
        text: String = "",
        cards: [CardDraft] = [],
        state: State = .streaming
    ) {
        self.id = id
        self.prompt = prompt
        self.text = text
        self.cards = cards
        self.state = state
    }


    /// Where the reply is in its lifecycle. `.failed` carries a user-facing
    /// reason - a guardrail violation, an exhausted context window, a model
    /// that turned out to be unavailable.
    enum State: Equatable {


        case streaming

        case completed

        case failed(String)


    }


}
