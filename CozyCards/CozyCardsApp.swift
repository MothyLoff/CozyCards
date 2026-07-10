import SwiftUI
import SwiftData


@main
struct CozyCardsApp: App {


    private let modelContainer: ModelContainer
    @State private var libraryStore: LibraryStore
    @State private var chatStore: ChatStore_


    init() {
        let container: ModelContainer
        do {
            container = try ModelContainer(
                for: LibraryItemModel_.self,
                LibraryDictionaryModel_.self,
                ChatThreadModel_.self,
                ChatMessageModel_.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }

        modelContainer = container
        libraryStore = LibraryStore(repository: SwiftDataLibraryRepository_(modelContainer: container))
        chatStore = ChatStore_(repository: SwiftDataChatRepository_(modelContainer: container))
    }


    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(libraryStore)
                .environment(chatStore)
        }
        .modelContainer(modelContainer)
    }


}
