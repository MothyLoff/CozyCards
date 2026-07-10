import FoundationModels



/// A vocabulary item the model produces from a user query.
///
/// `Card` is a tagged union: the case tells you what kind of item it is and
/// carries the fields that make sense for that kind. Switch over the case to
/// render or store it. The model fills only the fields that are relevant and
/// leaves the rest `nil`, so treat every optional as "may be absent".
///
/// `Codable` is not decoration. The storage layer persists a card whole, as a
/// `.codable` attribute, instead of flattening it into columns, so the encoding
/// of this type is a storage contract: renaming a case or a field breaks
/// decoding of rows already on disk.
@Generable
enum Card: Codable, Hashable, Sendable {


    case word(WordCardContent)

    case phrase(PhraseCardContent)

    case collocation(CollocationCardContent)

    case idiom(IdiomCardContent)

    case rule(RuleCardContent)


}



@Generable
struct WordCardContent: Codable, Hashable, Sendable {


    @Guide(description: "The word or term, in the language being learned")
    var term: String

    @Guide(description: "Part of speech, if applicable (noun, verb, adjective, ...)")
    var partOfSpeech: String?

    @Guide(description: "IPA transcription, only when it is useful")
    var transcription: String?

    @Guide(description: "A clear definition in the language being learned. Prefer this over a translation.")
    var definition: String?

    @Guide(description: "Translation into the user's native language, only when a definition is not enough")
    var translation: String?

    @Guide(description: "One to three natural example sentences using the word")
    var examples: [String]


}



@Generable
struct PhraseCardContent: Codable, Hashable, Sendable {


    @Guide(description: "The phrase, as it is actually used")
    var text: String

    @Guide(description: "What the phrase means, explained in the language being learned")
    var meaning: String?

    @Guide(description: "Translation into the user's native language, only when the explanation is not enough")
    var translation: String?

    @Guide(description: "One to three natural example sentences using the phrase")
    var examples: [String]


}



@Generable
struct CollocationCardContent: Codable, Hashable, Sendable {


    @Guide(description: "The collocation pattern, for example 'make a decision' or 'heavy rain'")
    var pattern: String

    @Guide(description: "How and when the collocation is used, in the language being learned")
    var meaning: String?

    @Guide(description: "Translation into the user's native language, only when the explanation is not enough")
    var translation: String?

    @Guide(description: "One to three natural example sentences using the collocation")
    var examples: [String]


}



@Generable
struct IdiomCardContent: Codable, Hashable, Sendable {


    @Guide(description: "The idiom")
    var text: String

    @Guide(description: "The actual, figurative meaning of the idiom")
    var figurativeMeaning: String

    @Guide(description: "The literal word-for-word reading, when the contrast helps understanding")
    var literalMeaning: String?

    @Guide(description: "Translation into the user's native language, only when the explanation is not enough")
    var translation: String?

    @Guide(description: "One to three natural example sentences using the idiom")
    var examples: [String]


}



@Generable
struct RuleCardContent: Codable, Hashable, Sendable {


    @Guide(description: "A short name for the rule")
    var title: String

    @Guide(description: "The rule stated clearly and concisely")
    var statement: String

    @Guide(description: "Examples that illustrate the rule in action")
    var examples: [String]


}



/// The kind of a `Card` without its payload.
///
/// Use it to filter or group the library without switching over the full value.
enum CardKind: String, CaseIterable, Hashable, Sendable {


    case word

    case phrase

    case collocation

    case idiom

    case rule


}



extension Card {


    /// The kind of this card, derived from its case.
    nonisolated var kind: CardKind {
        switch self {
        case .word: .word
        case .phrase: .phrase
        case .collocation: .collocation
        case .idiom: .idiom
        case .rule: .rule
        }
    }


}
