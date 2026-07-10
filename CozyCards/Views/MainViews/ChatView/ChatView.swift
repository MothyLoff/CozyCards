import SwiftUI



struct ChatView: View {
    @Binding var page: Page

    @Environment(ChatStore.self) private var chatStore
    @State private var prompt: String = ""
    @FocusState private var isInputFocused: Bool

    @Namespace private var namespace

    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    ForEach(chatStore.currentThread.messages) { message in
                        ChatUnitView(message: message)
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
            .overlay {
                if chatStore.availability != .available {
                    ModelUnavailableView(availability: chatStore.availability)
                }
            }
            // Loads model resources before the first prompt, cutting the wait
            // for the first token. Cheap and idempotent.
            .onAppear { chatStore.prewarm() }

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
                // There is no cloud fallback: without the model there is
                // nothing for the input to do.
                .disabled(chatStore.availability != .available)
            }
        }
        .padding(.horizontal, 32)

    }


}
