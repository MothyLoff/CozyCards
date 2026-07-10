import SwiftUI



struct WordCardContentView: View {


    @Binding var content: WordCardContent


    init(_ content: Binding<WordCardContent>) {
        self._content = content
    }


    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                CardField("Term", text: $content.term, font: .largeTitle.bold())

                HStack(spacing: 8) {
                    CardField(
                        "Part of speech",
                        text: $content.partOfSpeech.orEmpty,
                        font: .subheadline,
                        color: .secondary
                    )
                    .italic()

                    CardField(
                        "Transcription",
                        text: $content.transcription.orEmpty,
                        font: .subheadline,
                        color: .secondary
                    )
                    .monospaced()
                }
            }

            CardField("Definition", text: $content.definition.orEmpty)

            CardField("Translation", text: $content.translation.orEmpty, color: .secondary)

            CardExamplesView(examples: $content.examples)
        }
        .cardSurface()
    }


}



#Preview {
    WordCardContentView(.constant(.preview))
        .padding()
}
