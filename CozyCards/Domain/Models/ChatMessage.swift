import Foundation
import Observation
import FoundationModels



/// One turn in a chat: the user's prompt and the model's streaming answer.
///
/// `answer` updates live while `state` is `.streaming`. For a card answer the
/// payload is fully populated once `state` becomes `.completed`. UI observes
/// this object directly; there is no need to diff snapshots by hand.
@Observable
final class ChatMessage: Identifiable {


    let id: UUID

    let prompt: String

    var answer: Answer

    var state: State


    init(
        id: UUID = UUID(),
        prompt: String,
        answer: Answer = .none,
        state: State = .streaming
    ) {
        self.id = id
        self.prompt = prompt
        self.answer = answer
        self.state = state
    }


    /// What the model is replying with. A message is either a structured card
    /// or free text, decided as generation starts.
    enum Answer {


        case none

        case text(String)

        case card(Card.PartiallyGenerated)


    }


    /// Where the reply is in its lifecycle. `.failed` carries a user-facing reason.
    enum State: Equatable {


        case streaming

        case completed

        case failed(String)


    }


}
