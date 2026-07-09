import Foundation
import Observation



/// A single conversation: an ordered list of messages plus a title.
///
/// `title` may start empty and be filled in later (for example by the model);
/// while it is empty, UI can fall back to the first prompt.
@Observable
final class ChatThread: Identifiable {


    let id: UUID

    var title: String

    var messages: [ChatMessage]

    let createdAt: Date


    init(
        id: UUID = UUID(),
        title: String = "",
        messages: [ChatMessage] = [],
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.messages = messages
        self.createdAt = createdAt
    }


}
