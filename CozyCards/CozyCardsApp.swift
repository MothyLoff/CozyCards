import SwiftUI



@main
struct CozyCardsApp: App {


    @State private var libraryStore = LibraryStore(repository: InMemoryLibraryRepository())


    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(libraryStore)
        }
    }


}
