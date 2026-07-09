import SwiftUI



struct LibraryCategoryView: View {
    var category: String
    var words: [String]
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(category)
                .font(.title)
                .padding(.horizontal)
            ScrollView (.horizontal) {
                HStack {
                    ForEach(words, id:\.self) { word in
                        LibraryWordView(word: word)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(.bottom, 24)
        
    }
    
    
}



#Preview {
    
    LibraryCategoryView(category: "ComplicatedWords", words: [
        "serendipity", "quintessential",
        "epistemology", "incomprehensible",
        "institutionalization", "counterintuitive",
        "photosynthesis", "electroencephalograph",
        "interdisciplinary", "misrepresentation",
        "hyperresponsiveness", "cryptographically",
        "uncharacteristically", "disproportionately",

    ])
    
}
