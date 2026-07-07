import SwiftUI



struct ChatUnitView : View {
    let promptText: String
    let responseText: String
    
    var body : some View {
        VStack {
            PromptMessageView(prompt: promptText)
            ResponseMessageView(response: responseText)
        }
    }
}



#Preview {
    
    ChatUnitView(promptText: "Hi clanker", responseText: "hi hi bro")
    
}
