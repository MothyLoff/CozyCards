import Foundation



extension Card {


    /// The main headword or title of the card, regardless of kind.
    ///
    /// Use it for list rows and search without switching over the payload.
    nonisolated var primaryText: String {
        switch self {
        case .word(let card): card.term
        case .phrase(let card): card.text
        case .collocation(let card): card.pattern
        case .idiom(let card): card.text
        case .rule(let card): card.title
        }
    }


}



extension LibraryItem {


    /// Whether the item matches a free-text `query` by headword or tag.
    ///
    /// Case- and diacritic-insensitive. An empty query matches everything.
    nonisolated func matches(_ query: String) -> Bool {
        guard !query.isEmpty else { return true }
        if card.primaryText.localizedCaseInsensitiveContains(query) { return true }
        return tags.contains { $0.localizedCaseInsensitiveContains(query) }
    }


}
