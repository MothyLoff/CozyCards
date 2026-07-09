import SwiftUI
import SwiftData


@main
struct CozyCardsApp: App {


    private let modelContainer: ModelContainer
    @State private var libraryStore: LibraryStore


    init() {
        let container: ModelContainer
        do {
            container = try ModelContainer(for: LibraryItemModel_.self, LibraryDictionaryModel_.self)
        } catch {
            fatalError("Failed to create ModelContainer for LibraryItemModel_: \(error)")
        }

        modelContainer = container
        libraryStore = LibraryStore(repository: SwiftDataLibraryRepository_(modelContainer: container))
    }


    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(libraryStore)
        }
        .modelContainer(modelContainer)
    }


}
