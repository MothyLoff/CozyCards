import SwiftUI



struct RuleCardContentView: View {


    @Binding var content: RuleCardContent


    init(_ content: Binding<RuleCardContent>) {
        self._content = content
    }


    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            CardField("Rule", text: $content.title, font: .largeTitle.bold())

            CardField("What the rule says", text: $content.statement)

            CardExamplesView(examples: $content.examples)
        }
        .cardSurface()
    }


}



#Preview {
    RuleCardContentView(.constant(.preview))
        .padding()
}
