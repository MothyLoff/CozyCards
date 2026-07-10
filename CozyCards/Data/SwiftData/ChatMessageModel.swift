import Foundation
import SwiftData



/// On-disk row for one `ChatMessage`.
///
/// Persists the turn's free text, not its cards. `ChatMessage.cards` holds
/// `CardDraft`s wrapping a `Card`, and `Card` has no storage form yet, so a
/// reopened thread shows the text of a reply but not the cards it produced.
/// A card the user saved survives on its own, as a `LibraryItemModel`.
/// Widening this is tracked separately; when it lands, only this file changes.
@Model
final class ChatMessageModel {


    @Attribute(.unique) var id: UUID
    var prompt: String
    var createdAt: Date

    var text: String

    var stateKind: String    // "streaming" | "completed" | "failed"
    var failureReason: String?

    var thread: ChatThreadModel?


    init(message: ChatMessage) {
        id = message.id
        prompt = message.prompt
        createdAt = .now
        text = ""
        stateKind = "streaming"
        failureReason = nil

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
    }


    func toDomain() -> ChatMessage {
        let state: ChatMessage.State
        switch stateKind {
        case "completed": state = .completed
        case "failed": state = .failed(failureReason ?? "Something went wrong")
        default: state = .streaming
        }

        return ChatMessage(id: id, prompt: prompt, text: text, cards: [], state: state)
    }


}
