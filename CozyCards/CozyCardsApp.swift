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
                ChatThreadModel.self,
                ChatMessageModel.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }

        modelContainer = container

        // One library repository, two owners: the library screen reads it, chat
        // writes into it when the model produces a card. Two instances would
        // each keep their own `observe()` subscribers, and the library screen
        // would not notice a card arriving from chat.
        let library = SwiftDataLibraryRepository(modelContainer: container)

        libraryStore = LibraryStore(repository: library)
        chatStore = ChatStore(
            repository: SwiftDataChatRepository(modelContainer: container),
            library: library,
            language: AppleFoundationLanguageModel()
        )
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
