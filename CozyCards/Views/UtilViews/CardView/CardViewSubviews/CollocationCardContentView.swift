import SwiftUI



struct CollocationCardContentView: View {


    @Binding var content: CollocationCardContent


    init(_ content: Binding<CollocationCardContent>) {
        self._content = content
    }


    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            CardField("Collocation", text: $content.pattern, font: .largeTitle.bold())

            CardField("Meaning", text: $content.meaning.orEmpty)

            CardField("Translation", text: $content.translation.orEmpty, color: .secondary)

            CardExamplesView(examples: $content.examples)
        }
        .cardSurface()
    }


}



#Preview {
    CollocationCardContentView(.constant(.preview))
        .padding()
}
