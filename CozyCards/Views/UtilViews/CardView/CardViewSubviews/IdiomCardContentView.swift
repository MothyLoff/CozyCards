import SwiftUI



struct IdiomCardContentView: View {


    @Binding var content: IdiomCardContent


    @Environment(\.isEnabled) private var isEnabled


    init(_ content: Binding<IdiomCardContent>) {
        self._content = content
    }


    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            CardField("Idiom", text: $content.text, font: .largeTitle.bold())

            CardField("What it actually means", text: $content.figurativeMeaning)

            if showsLiteralMeaning {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("literally")
                        .font(.caption)
                        .foregroundStyle(.tertiary)

                    CardField(
                        "Word-for-word reading",
                        text: $content.literalMeaning.orEmpty,
                        color: .secondary
                    )
                }
            }

            CardField("Translation", text: $content.translation.orEmpty, color: .secondary)

            CardExamplesView(examples: $content.examples)
        }
        .cardSurface()
    }


    /// The "literally" label must not appear next to an empty field while a card
    /// is streaming, so the whole row is dropped until there is something to show.
    private var showsLiteralMeaning: Bool {
        isEnabled || !(content.literalMeaning ?? "").isEmpty
    }


}



#Preview {
    IdiomCardContentView(.constant(.preview))
        .padding()
}
