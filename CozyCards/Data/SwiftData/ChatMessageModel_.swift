import Foundation
import SwiftData



/// On-disk row for one `ChatMessage`.
///
/// `ChatMessage.Answer` also has a `.card(Card.PartiallyGenerated)` case,
/// but nothing in the current chat flow produces card answers yet
/// (`ChatViewModel`/`LanguageModelService` only stream plain text) — so this
/// only persists `.none` / `.text` faithfully. A `.card` answer is stored as
/// a bare kind marker for now; wire in real fields here once card
/// generation is actually driving chat answers.
@Model
final class ChatMessageModel_ {


    @Attribute(.unique) var id: UUID
    var prompt: String
    var createdAt: Date

    var answerKind: String   // "none" | "text" | "card"
    var answerText: String?

    var stateKind: String    // "streaming" | "completed" | "failed"
    var failureReason: String?

    var thread: ChatThreadModel_?


    init(message: ChatMessage) {
        id = message.id
        prompt = message.prompt
        createdAt = .now
        answerKind = "none"
        answerText = nil
        stateKind = "streaming"
        failureReason = nil

        apply(message: message)
    }


    func apply(message: ChatMessage) {
        switch message.answer {
        case .none:
            answerKind = "none"
            answerText = nil
        case .text(let text):
            answerKind = "text"
            answerText = text
        case .card:
            answerKind = "card"
            answerText = nil
        }

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
    }


    func toDomain() -> ChatMessage {
        let answer: ChatMessage.Answer
        switch answerKind {
        case "text": answer = .text(answerText ?? "")
        default: answer = .none // "card" isn't reconstructable yet, see note above
        }

        let state: ChatMessage.State
        switch stateKind {
        case "completed": state = .completed
        case "failed": state = .failed(failureReason ?? "Something went wrong")
        default: state = .streaming
        }

        return ChatMessage(id: id, prompt: prompt, answer: answer, state: state)
    }


}
