import SwiftUI



struct ChatView: View {
    @State private var chatViewModel = ChatViewModel()
    @State private var prompt: String = ""
    
    @Namespace private var namespace
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    ForEach(chatViewModel.messages, id:\.self.id) { message in
                        ChatUnitView(promptText: message.prompt, responseText: message.response)
                    }
                }
            }
            .defaultScrollAnchor(.bottom)
            .scrollIndicators(.hidden)
            .safeAreaInset(edge: .bottom) {
                GlassEffectContainer {
                    HStack {
                        TextField("Ask about words..", text: $prompt, axis: .vertical)
                            .lineLimit(1...5)
                            .padding()
                            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 32))
                            .glassEffectID("input", in: namespace)
                        
                        if !prompt.isEmpty {
                            Button {
                                Task {
                                    let tmpPrompt = prompt
                                    prompt = ""
                                    
                                    if tmpPrompt != "" {
                                        await chatViewModel.newMessage(prompt: tmpPrompt)
                                    }
                                }
                            } label: {
                                Image(systemName: "arrow.turn.right.up")
                                    .padding()
                                    .glassEffect(.regular.interactive())
                                    .glassEffectID("send", in: namespace)
                            }
                        }
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

