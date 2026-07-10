import SwiftUI



struct ChatUnitView: View {


    var message: ChatMessage


    var body: some View {
        VStack {
            PromptMessageView(prompt: message.prompt)
            ResponseMessageView(response: responseText)
        }
    }


    /// Cards are not rendered yet: the model only streams text for now, so
    /// `message.cards` is always empty. Card rendering lands with `streamCard`.
    private var responseText: String {
        if message.text.isEmpty {
            return message.state == .streaming ? "…" : ""
        }
        return message.text
    }


}



#Preview {


    ChatUnitView(message: ChatMessage(prompt: "Hi clanker", text: "hi hi bro", state: .completed))


}
