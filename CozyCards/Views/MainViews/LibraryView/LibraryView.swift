import SwiftUI



struct LibraryView: View {
    
    var body: some View {
        ScrollView {
            VStack {
                LibraryCategoryView(category: "ComplicatedWords", words: [
                    "serendipity", "quintessential",
                    "epistemology", "incomprehensible",
                    "institutionalization", "counterintuitive",
                    "photosynthesis", "electroencephalograph",
                    "interdisciplinary", "misrepresentation",
                    "hyperresponsiveness", "cryptographically",
                    "uncharacteristically", "disproportionately",

                ])
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
        }
        .scrollIndicators(.hidden)
        
    }
    
    
}


#Preview {
    
    LibraryView()
    
}
