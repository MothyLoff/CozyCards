import SwiftUI
import SwiftData


@main
struct CozyCardsApp: App {


    @State private var libraryStore = LibraryStore(repository: InMemoryLibraryRepository())


    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(libraryStore)
        }
        .modelContainer(for: [Chat.self, WordDictionary.self, WordCard.self])
    }


}
