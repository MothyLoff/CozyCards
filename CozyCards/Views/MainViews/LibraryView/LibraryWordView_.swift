import SwiftUI



struct LibraryWordView_: View {

    @State private var detailsPresented = false

    var item: LibraryItem

    var body: some View {
        Button {
            detailsPresented = true
        } label: {
            Text(item.card.primaryText)
                .font(.headline)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 32)
                        .foregroundStyle(.background.secondary)
                }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $detailsPresented) {
            LibraryWordDetailsView_(mode: .edit(item))
                .presentationDetents([.fraction(0.4)])
        }
    }


}


#Preview {

    LibraryWordView_(item: LibraryItem(card: .word(WordCardContent(
        term: "word!!",
        partOfSpeech: nil,
        transcription: nil,
        definition: "lololo",
        translation: nil,
        examples: []
    ))))
    .environment(LibraryStore(repository: InMemoryLibraryRepository()))
    .preferredColorScheme(.dark)

}
