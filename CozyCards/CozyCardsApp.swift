import SwiftUI
import SwiftData


@main
struct CozyCardsApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [ChatSession.self, WordDictionary.self, WordCard.self])
    }
}
