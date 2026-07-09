import SwiftUI



struct ChatView: View {
    @Binding var page : Page
    
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
            
            .safeAreaInset(edge: .top) {
                HStack {
                    Button {
                        withAnimation(.spring(duration: 0.2)) {
                            page = .history
                        }
                        
                    } label: {
                        Image(systemName: "line.horizontal.3.decrease")
                            .padding()
                    }
                    .glassEffect(.regular.interactive())
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.spring(duration: 0.2)) {
                            page = .library
                        }
                    } label: {
                        Image(systemName: "book")
                            .padding()
                    }
                    .glassEffect(.regular.interactive())
                }
            }
            
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
                            }
                            .glassEffect(.regular.interactive())
                            .glassEffectID("send", in: namespace)
                        }
                        
                    }
                }
                .animation(.spring(duration: 0.2), value: prompt.isEmpty)
            }
        }
        .padding(.horizontal, 32)

    }
    
    
}



//#Preview {
//    
//    ChatView()
//        .preferredColorScheme(.dark)
//    
//}
