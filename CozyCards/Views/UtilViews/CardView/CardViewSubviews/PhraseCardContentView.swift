import SwiftUI



struct PhraseCardContentView: View {


    @Binding var content: PhraseCardContent


    init(_ content: Binding<PhraseCardContent>) {
        self._content = content
    }


    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            CardField("Phrase", text: $content.text, font: .largeTitle.bold())

            CardField("Meaning", text: $content.meaning.orEmpty)

            CardField("Translation", text: $content.translation.orEmpty, color: .secondary)

            CardExamplesView(examples: $content.examples)
        }
        .cardSurface()
    }


}



#Preview {
    PhraseCardContentView(.constant(.preview))
        .padding()
}
