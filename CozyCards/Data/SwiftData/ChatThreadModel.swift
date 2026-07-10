import Foundation
import SwiftData



/// On-disk row for a `ChatThread`, owning its `ChatMessageModel` rows.
@Model
final class ChatThreadModel {


    @Attribute(.unique) var id: UUID
    var title: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \ChatMessageModel.thread)
    var messages: [ChatMessageModel] = []

    /// The model's own `Transcript` for this thread, encoded as JSON.
    /// Lets a reopened thread resume with real model context instead of
    /// just replaying saved message text. `Transcript` isn't produced by
    /// this app — it's read from `LanguageModelSession.transcript` — so
    /// there's no domain-model equivalent to convert to/from; this column
    /// is written and read directly by `SwiftDataChatRepository`.
    @Attribute(.externalStorage) var transcriptData: Data?


    init(thread: ChatThread) {
        id = thread.id
        title = thread.title
        createdAt = thread.createdAt
        messages = []
        transcriptData = nil
    }


    func toDomain() -> ChatThread {
        let orderedRows = messages.sorted { $0.createdAt < $1.createdAt }
        return ChatThread(
            id: id,
            title: title,
            messages: orderedRows.map { $0.toDomain() },
            createdAt: createdAt
        )
    }


}
