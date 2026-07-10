import SwiftUI



struct ChatView_: View {
    @Binding var page: Page

    @Environment(ChatStore_.self) private var chatStore
    @State private var prompt: String = ""
    @FocusState private var isInputFocused: Bool

    @Namespace private var namespace

    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    ForEach(chatStore.currentThread.messages) { message in
                        ChatUnitView_(message: message)
                    }
                }
            }
            .defaultScrollAnchor(.bottom)
            .scrollIndicators(.hidden)
            // Swipe down on the message list to dismiss the keyboard,
            // same as Messages/most chat apps.
            .scrollDismissesKeyboard(.interactively)
            .onTapGesture {
                isInputFocused = false
            }

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
                            .focused($isInputFocused)
                            .padding()
                            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 32))
                            .glassEffectID("input", in: namespace)

                        if !prompt.isEmpty {
                            Button {
                                Task {
                                    let tmpPrompt = prompt
                                    prompt = ""

                                    if tmpPrompt != "" {
                                        await chatStore.send(prompt: tmpPrompt)
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
