import Foundation
import FoundationModels


class LanguageModelService {
    private let session = LanguageModelSession()
    
    func getResponseWithStream(prompt: String) -> LanguageModelSession.ResponseStream<String> {
        let stream = session.streamResponse(to: prompt)
        return stream
    }
}
