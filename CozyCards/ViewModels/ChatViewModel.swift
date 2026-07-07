import Foundation
import Observation
import FoundationModels


@Observable
final class LanguageModelMessage: Identifiable {
    let id: UUID = UUID()
    let prompt: String
    var response: String = ""
    var completed: Bool = false

    init(prompt: String) {
        self.prompt = prompt
    }

    public func isCompleted() -> Bool {
        return completed
    }
}


@MainActor
@Observable
final class ChatViewModel {
    var messages: [LanguageModelMessage] = []

    private let languageModelService = LanguageModelService()

    public func newMessage(prompt: String) async {
        let message = LanguageModelMessage(prompt: prompt)
        messages.append(message)

        do {
            for try await partialResponse in languageModelService.getResponseWithStream(prompt: prompt) {
                message.response = partialResponse.content
            }
        } catch {
            print("Error generating LLM response:", error)
        }

        message.completed = true
    }
}
