#if DEBUG

import Foundation



/// A `LanguageModeling` that answers from a script.
///
/// Previews and simulators without Apple Intelligence cannot open a real
/// session, and a `#Preview` that silently renders an error state teaches you
/// nothing about the view you are building. This one streams a short reply and,
/// unless told otherwise, one card - the shape a real turn has.
struct MockLanguageModel: LanguageModeling {


    var availability: ModelAvailability = .available

    var reply: String = "It comes up most often in writing. In speech people reach for something plainer."

    var card: Card? = .word(.preview)


    func makeSession(restoring transcript: Data?) -> any ChatSessioning {
        MockChatSession(reply: reply, card: card)
    }


}



nonisolated final class MockChatSession: ChatSessioning, @unchecked Sendable {


    private let reply: String
    private let card: Card?


    init(reply: String, card: Card?) {
        self.reply = reply
        self.card = card
    }


    func prewarm() {}

    func encodedTranscript() -> Data? { nil }

    func reset() {}


    /// Words arrive one at a time so a preview shows the same growth a real
    /// turn shows; the card lands first, the way a tool call precedes the prose
    /// that comments on it.
    func respond(to prompt: String) -> AsyncThrowingStream<TurnEvent, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                if let card {
                    try? await Task.sleep(for: .milliseconds(400))
                    continuation.yield(.card(card))
                }

                var text = ""
                for word in reply.split(separator: " ") {
                    try? await Task.sleep(for: .milliseconds(60))
                    text += text.isEmpty ? String(word) : " \(word)"
                    continuation.yield(.text(text))
                }

                continuation.finish()
            }

            continuation.onTermination = { _ in task.cancel() }
        }
    }


}

#endif
