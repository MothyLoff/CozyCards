import Foundation
import SwiftData



/// A named collection of words, e.g. "Complicated words" or "Phrasal verbs".
///
/// Membership is tracked the simple way: a `LibraryItem` belongs to a
/// dictionary when one of its `tags` equals that dictionary's `name`. That
/// keeps `LibraryItem` / `LibraryRepository` completely untouched — this
/// model only adds the list of dictionary *names* the UI shows, it doesn't
/// own the words themselves.
@Model
final class LibraryDictionaryModel_ {


    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date


    init(name: String, createdAt: Date = .now) {
        self.id = UUID()
        self.name = name
        self.createdAt = createdAt
    }


}
