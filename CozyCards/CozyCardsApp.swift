import SwiftUI
import SwiftData


@main
struct CozyCardsApp: App {


    private let modelContainer: ModelContainer
    @State private var libraryStore: LibraryStore
    @State private var chatStore: ChatStore


    init() {
        let container: ModelContainer
        do {
            container = try ModelContainer(
                for: LibraryItemModel.self,
                LibraryDictionaryModel.self,
                ChatThreadModel.self,
                ChatMessageModel.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }

        modelContainer = container
        libraryStore = LibraryStore(repository: SwiftDataLibraryRepository(modelContainer: container))
        chatStore = ChatStore(repository: SwiftDataChatRepository(modelContainer: container))
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
