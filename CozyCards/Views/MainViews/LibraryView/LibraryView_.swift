import SwiftUI
import SwiftData



struct LibraryView_: View {

    @Environment(LibraryStore.self) private var store
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \LibraryDictionaryModel_.createdAt) private var dictionaries: [LibraryDictionaryModel_]

    @State private var isAddingDictionary = false
    @State private var newDictionaryName = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if dictionaries.isEmpty {
                    ContentUnavailableView(
                        "No dictionaries yet",
                        systemImage: "book",
                        description: Text("Tap + to create your first dictionary.")
                    )
                    .padding(.top, 64)
                } else {
                    ForEach(dictionaries, id: \.id) { dictionary in
                        LibraryCategoryView_(
                            dictionaryName: dictionary.name,
                            words: store.items.filter { $0.tags.contains(dictionary.name) }
                        )
                    }
                }
            }
            .padding(.top)
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                Button {
                    isAddingDictionary = true
                } label: {
                    Image(systemName: "plus")
                        .padding()
                }
                .glassEffect(.regular.interactive())
            }
            .padding(.horizontal)
        }
        .alert("New dictionary", isPresented: $isAddingDictionary) {
            TextField("Name", text: $newDictionaryName)
            Button("Cancel", role: .cancel) { newDictionaryName = "" }
            Button("Create") { createDictionary() }
        }
    }


    private func createDictionary() {
        let name = newDictionaryName.trimmingCharacters(in: .whitespaces)
        newDictionaryName = ""
        guard !name.isEmpty else { return }
        modelContext.insert(LibraryDictionaryModel_(name: name))
        try? modelContext.save()
    }


}


#Preview {

    LibraryView_()
        .environment(LibraryStore(repository: InMemoryLibraryRepository()))
        .modelContainer(for: [LibraryDictionaryModel_.self, LibraryItemModel_.self])

}
