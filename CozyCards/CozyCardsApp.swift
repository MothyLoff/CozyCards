import SwiftUI
import SwiftData


@main
struct CozyCardsApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [Chat.self, WordDictionary.self, WordCard.self])
    }
}
