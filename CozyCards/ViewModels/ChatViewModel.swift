import Foundation
import Observation
import FoundationModels


class LanguageModelMessage {
    public var id: UUID = UUID()
    public var prompt: String
    public var responseStream : LanguageModelSession.ResponseStream<String>
    public var response: String = ""
    
    var completed: Bool
    
    init(prompt: String, responseStream: LanguageModelSession.ResponseStream<String>) async {
        self.prompt = prompt
        self.responseStream = responseStream
        self.completed = false
        
        do {
            for try await partialResponse in self.responseStream {
                self.response = partialResponse.content
            }
        } catch {
            print("Error generating LLM response:", error)
        }
        
        self.completed = true
    }
    
    public func isCompleted() -> Bool {
        return completed
    }
}


@Observable
final class ChatViewModel {
    var messages: [LanguageModelMessage] = []
    
    private let languageModelService = LanguageModelService()
    
    public func newMessage(prompt: String) async {
        let responseStream = languageModelService.getResponseWithStream(prompt: prompt)
        messages.append(await LanguageModelMessage(prompt: prompt, responseStream: responseStream))
    }
}
