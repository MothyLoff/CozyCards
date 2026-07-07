import SwiftUI



struct ChatView: View {
    @State var prompt: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            ScrollView {
                VStack {
                    PromptMessageView(prompt: "Hey bro")
                    ResponseMessageView(response: "Hi Hi")
                }
            }
            TextField("Ask about words..", text: $prompt)
                .padding()
                .glassEffect()
        }
        .padding(.horizontal, 32)

    }
    
    
}

#Preview {
    
    ChatView()
        .preferredColorScheme(.dark)
    
}
