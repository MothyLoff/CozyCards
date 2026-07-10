import SwiftUI



struct ChatUnitView_: View {
    var message: ChatMessage

    var body: some View {
        VStack {
            PromptMessageView(prompt: message.prompt)
            ResponseMessageView(response: responseText)
        }
    }

    private var responseText: String {
        switch message.answer {
        case .none:
            return message.state == .streaming ? "…" : ""
        case .text(let text):
            return text
        case .card:
            // Card-generating answers aren't produced by chat yet — once
            // `streamCard` drives replies, render an actual card here.
            return "[card]"
        }
    }
}



#Preview {

    ChatUnitView_(message: ChatMessage(prompt: "Hi clanker", answer: .text("hi hi bro"), state: .completed))

}
