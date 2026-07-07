import SwiftUI



struct ChatView: View {
    @State private var chatViewModel = ChatViewModel()
    @State private var prompt: String = ""
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    ForEach(chatViewModel.messages, id:\.self.id) { message in
                        ChatUnitView(promptText: message.prompt, responseText: message.response)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    TextField("Ask about words..", text: $prompt)
                        .padding()
                        .glassEffect()
                    Button {
                        Task {
                            let tmpPrompt = prompt
                            prompt = ""
                            
                            await chatViewModel.newMessage(prompt: tmpPrompt)
                        }
                    } label: {
                        Image(systemName: "arrow.turn.right.up")
                            .padding()
                            .glassEffect()
                    }
                }
                
            }
        }
        .padding(.horizontal, 32)

    }
    
    
}

#Preview {
    
    ChatView()
        .preferredColorScheme(.dark)
    
}

