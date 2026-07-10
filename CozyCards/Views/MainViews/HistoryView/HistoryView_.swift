import SwiftUI



struct HistoryView_: View {

    @Environment(ChatStore_.self) private var chatStore

    @Binding var page: Page
    @State var chatsSearch: String = ""

    @Namespace private var footerNamespace

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Recent chats")
                    .font(.title)
                    .padding(.horizontal)

                if filteredThreads.isEmpty {
                    Text("No chats yet")
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                } else {
                    ForEach(filteredThreads) { thread in
                        HistoryChatUnitView_(thread: thread, page: $page)
                            .padding(.vertical, 6)
                        Divider()
                    }
                }
            }
        }
        .defaultScrollAnchor(.top)
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom) {
            GlassEffectContainer {
                HStack {

                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)

                        TextField("Search in chats..", text: $chatsSearch)
                    }
                    .padding()
                    .glassEffect(.regular.interactive())
                    .glassEffectID("search", in: footerNamespace)

                    Button {
                        withAnimation(.spring(duration: 0.2)) {
                            chatStore.startNewThread()
                            page = .chat
                        }
                    } label: {
                        Image(systemName: "pencil")
                            .padding()

                    }
                    .glassEffect(.regular.interactive())
                    .glassEffectID("new", in: footerNamespace)

                }
                .padding(.horizontal)
            }

        }
    }

    private var filteredThreads: [ChatThread] {
        chatStore.threads.filter { thread in
            chatsSearch.isEmpty || displayTitle(for: thread).localizedCaseInsensitiveContains(chatsSearch)
        }
    }

    private func displayTitle(for thread: ChatThread) -> String {
        if !thread.title.isEmpty { return thread.title }
        if let firstPrompt = thread.messages.first?.prompt, !firstPrompt.isEmpty { return firstPrompt }
        return "New chat"
    }


}
