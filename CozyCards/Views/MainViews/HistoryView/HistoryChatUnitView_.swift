import SwiftUI



struct HistoryChatUnitView_: View {
    var thread: ChatThread

    @Binding var page: Page

    @Environment(ChatStore_.self) private var chatStore

    var body: some View {

        Button {
            withAnimation(.spring(duration: 0.2)) {
                page = .chat
            }
            Task {
                await chatStore.open(thread)
            }
        } label: {
            Text(displayTitle)
                .lineLimit(1)
        }
        .padding(.horizontal)
        .buttonStyle(.plain)

    }

    private var displayTitle: String {
        if !thread.title.isEmpty { return thread.title }
        if let firstPrompt = thread.messages.first?.prompt, !firstPrompt.isEmpty { return firstPrompt }
        return "New chat"
    }
}
