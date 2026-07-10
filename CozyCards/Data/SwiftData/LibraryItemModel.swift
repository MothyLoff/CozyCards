import Foundation
import SwiftData



/// On-disk row for a saved word.
///
/// Scoped down to the `.word` case of `Card` on purpose — `term` and
/// `definition` are all the current UI needs. `toDomain()`/`init(item:)`
/// still produce/consume a full `LibraryItem`/`Card`, so nothing else in
/// the app needs to know this is word-only; widening it to the other
/// `Card` kinds later only touches this file and `SwiftDataLibraryRepository`.
@Model
final class LibraryItemModel {


    @Attribute(.unique) var id: UUID
    var term: String
    var definition: String?
    var tags: [String]
    var createdAt: Date
    var sourceMessageID: UUID?


    init(item: LibraryItem) {
        id = item.id
        tags = item.tags
        createdAt = item.createdAt
        sourceMessageID = item.sourceMessageID

        if case .word(let content) = item.card {
            term = content.term
            definition = content.definition
        } else {
            // Only .word is supported right now; fall back to the card's
            // headword so nothing crashes if this ever gets hit.
            term = item.card.primaryText
            definition = nil
        }
    }


    func apply(_ item: LibraryItem) {
        tags = item.tags
        sourceMessageID = item.sourceMessageID
        if case .word(let content) = item.card {
            term = content.term
            definition = content.definition
        }
    }


    func toDomain() -> LibraryItem {
        LibraryItem(
            id: id,
            card: .word(WordCardContent(
                term: term,
                partOfSpeech: nil,
                transcription: nil,
                definition: definition,
                translation: nil,
                examples: []
            )),
            tags: tags,
            createdAt: createdAt,
            sourceMessageID: sourceMessageID
        )
    }


}
