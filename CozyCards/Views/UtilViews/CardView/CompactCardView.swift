import SwiftUI



/// The one-glance form of a card: headword plus a single line of context.
///
/// Read-only by design - tapping it is expected to open `CardView` in a sheet,
/// which is where a card is edited.
struct CompactCardView: View {


    let card: Card


    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(card.primaryText)
                .font(.headline)

            if let summary = card.summaryText {
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .cardSurface()
    }


}



private extension Card {


    /// The single line that best explains the card, if the model produced one.
    var summaryText: String? {
        let summary = switch self {
        case .word(let content): content.definition ?? content.translation
        case .phrase(let content): content.meaning ?? content.translation
        case .collocation(let content): content.meaning ?? content.translation
        case .idiom(let content): content.figurativeMeaning
        case .rule(let content): content.statement
        }

        return (summary?.isEmpty ?? true) ? nil : summary
    }


}



#Preview {
    VStack(spacing: 12) {
        CompactCardView(card: .word(.preview))
        CompactCardView(card: .idiom(.preview))
        CompactCardView(card: .rule(.preview))
    }
    .padding()
}
