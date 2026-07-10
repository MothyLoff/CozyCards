import SwiftUI



/// The full form of a card, dispatching on its kind.
///
/// Editability comes from the environment, not from a parameter: apply
/// `.disabled(true)` while a card streams in chat and the fields render as text,
/// hiding themselves until the model fills them. Drop the modifier in a sheet
/// and the same fields become editable.
struct CardView: View {


    @Binding var card: Card


    var body: some View {
        switch card {
        case .word(let content):
            WordCardContentView(binding(content, Card.word))

        case .phrase(let content):
            PhraseCardContentView(binding(content, Card.phrase))

        case .collocation(let content):
            CollocationCardContentView(binding(content, Card.collocation))

        case .idiom(let content):
            IdiomCardContentView(binding(content, Card.idiom))

        case .rule(let content):
            RuleCardContentView(binding(content, Card.rule))
        }
    }


    /// Projects a binding to the payload of the case the card is currently in.
    private func binding<Content>(
        _ content: Content,
        _ wrap: @escaping (Content) -> Card
    ) -> Binding<Content> {
        Binding(
            get: { content },
            set: { card = wrap($0) }
        )
    }


}



#Preview("Editable") {
    ScrollView {
        VStack(spacing: 16) {
            CardView(card: .constant(.word(.preview)))
            CardView(card: .constant(.idiom(.preview)))
            CardView(card: .constant(.rule(.preview)))
        }
        .padding()
    }
}



#Preview("Streaming") {
    ScrollView {
        VStack(spacing: 16) {
            CardView(card: .constant(.word(.preview)))
            CardView(card: .constant(.idiom(.preview)))
            CardView(card: .constant(.rule(.preview)))
        }
        .padding()
    }
    .disabled(true)
}
