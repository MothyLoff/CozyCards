import SwiftUI
import SwiftData



struct ChatUnitView: View {


    var message: ChatMessage

    @Environment(ChatStore.self) private var chatStore


    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            PromptMessageView(prompt: message.prompt)

            ForEach(message.cards) { draft in
                ChatCardView(draft: draft) {
                    chatStore.discard(draft)
                }
            }

            if !responseText.isEmpty {
                ResponseMessageView(response: responseText)
            }

            if case .failed(let reason) = message.state {
                Text(reason)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }


    /// While a turn streams and the model has said nothing yet, an ellipsis
    /// stands in for the text. A turn that produced only a card and no prose is
    /// complete and shows nothing here.
    private var responseText: String {
        if message.text.isEmpty {
            return message.state == .streaming ? "…" : ""
        }
        return message.text
    }


}



/// A card inside the chat transcript.
///
/// By the time it is drawn the card is already in the library - the button takes
/// that back. `CardView` is reused as-is under `.disabled(true)`: its fields
/// render as text and empty ones hide themselves, which is exactly the read-only
/// form a transcript wants. `CompactCardView` would show a headword and one
/// line, and the rest of it is the answer to the question that was asked.
private struct ChatCardView: View {


    let draft: CardDraft

    let onDiscard: () -> Void


    var body: some View {
        switch draft.state {
        case .discarded:
            Label("Removed from library", systemImage: "tray.and.arrow.up")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .cardSurface()

        case .saved:
            VStack(alignment: .trailing, spacing: 8) {
                CardView(card: .constant(draft.card))
                    .disabled(true)

                Button(action: onDiscard) {
                    Label("Remove from library", systemImage: "arrow.uturn.backward")
                }
                .font(.footnote)
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
    }


}



#Preview("Card, then prose") {


    let container = try! ModelContainer(
        for: LibraryItemModel.self,
        ChatThreadModel.self,
        ChatMessageModel.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let message = ChatMessage(
        prompt: "what does serendipity mean?",
        text: "You will meet it in writing far more often than in speech.",
        state: .completed
    )
    message.cards = [CardDraft(card: .word(.preview), libraryItemID: UUID())]

    return ScrollView {
        ChatUnitView(message: message)
            .padding()
    }
    .environment(ChatStore(
        repository: SwiftDataChatRepository(modelContainer: container),
        library: InMemoryLibraryRepository(),
        language: MockLanguageModel()
    ))


}
