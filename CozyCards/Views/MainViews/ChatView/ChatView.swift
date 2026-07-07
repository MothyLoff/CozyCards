import SwiftUI



struct ChatView: View {
    @State var prompt: String = ""
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    ChatUnitView(promptText: "Hi clanker", responseText: "hi hi bro")
                }
            }
            .safeAreaInset(edge: .bottom) {
                TextField("Ask about words..", text: $prompt)
                    .padding()
                    .glassEffect()
            }
        }
        .padding(.horizontal, 32)

    }
    
    
}

#Preview {
    
    ChatView()
        .preferredColorScheme(.dark)
    
}

