import SwiftUI



/// One dictionary rendered the way the original mockup rendered a category:
/// a title followed by a horizontally scrolling row of words. The only
/// addition is the small "+" next to the title, to add a word straight into
/// this dictionary.
struct LibraryCategoryView: View {

    var dictionaryName: String
    var words: [LibraryItem]

    @State private var isAddingWord = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(dictionaryName)
                    .font(.title)
                Spacer()
                Button {
                    isAddingWord = true
                } label: {
                    Image(systemName: "plus.circle")
                }
            }
            .padding(.horizontal)

            if words.isEmpty {
                Text("No words yet")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(words) { item in
                            LibraryWordView(item: item)
                        }
                    }
                    .padding(.horizontal)
                }
                .scrollIndicators(.hidden)
            }
        }
        .padding(.bottom, 24)
        .sheet(isPresented: $isAddingWord) {
            LibraryWordDetailsView(mode: .new(dictionaryName: dictionaryName))
                .presentationDetents([.fraction(0.4)])
        }
    }


}



#Preview {

    LibraryCategoryView(
        dictionaryName: "ComplicatedWords",
        words: [
            LibraryItem(card: .word(WordCardContent(
                term: "serendipity", partOfSpeech: nil, transcription: nil,
                definition: nil, translation: nil, examples: []
            ))),
            LibraryItem(card: .word(WordCardContent(
                term: "quintessential", partOfSpeech: nil, transcription: nil,
                definition: nil, translation: nil, examples: []
            ))),
        ]
    )
    .environment(LibraryStore(repository: InMemoryLibraryRepository()))

}
