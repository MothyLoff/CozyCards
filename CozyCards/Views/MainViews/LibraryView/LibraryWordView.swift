import SwiftUI



struct LibraryWordView: View {
    @State private var detailsPresented = false
    
    var word: String
    var description: String = ""
    
    var body: some View {
        Button {
            detailsPresented = true
        } label: {
            Text(word)
                .font(.headline)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 32)
                        .foregroundStyle(.background.secondary)
                }
        }
        .buttonStyle(.plain)
//        .glassEffect(.regular.interactive())
        .sheet(isPresented: $detailsPresented) {
            LibraryWordDetailsView(word: word, description: "lololo")
                .presentationDetents([.fraction(0.4)])
        }

    }
}


#Preview {
    LibraryWordView(word: "word!!")
        .preferredColorScheme(.dark)
}
