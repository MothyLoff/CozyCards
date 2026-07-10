import Foundation



// Streaming snapshots have every field optional; the card views work on a
// complete `Card` so that one set of views serves both streaming and editing.
// Lifting fills the gaps with empty values, which the views read as "not here
// yet" and hide. A lifted card is a view-layer value only: it may carry an
// empty `term`, so it must never reach `LibraryItem`. Save the final card the
// stream produces, not this one.


extension Card {


    /// Fails while the payload of the chosen case has not started arriving:
    /// the model picks the kind before it fills anything in, so there is a
    /// window in which there is no card to show yet.
    init?(partial: Card.PartiallyGenerated) {
        switch partial {
        case .word(let content):
            guard let content else { return nil }
            self = .word(WordCardContent(partial: content))

        case .phrase(let content):
            guard let content else { return nil }
            self = .phrase(PhraseCardContent(partial: content))

        case .collocation(let content):
            guard let content else { return nil }
            self = .collocation(CollocationCardContent(partial: content))

        case .idiom(let content):
            guard let content else { return nil }
            self = .idiom(IdiomCardContent(partial: content))

        case .rule(let content):
            guard let content else { return nil }
            self = .rule(RuleCardContent(partial: content))
        }
    }


}



extension WordCardContent {


    init(partial: PartiallyGenerated) {
        self.init(
            term: partial.term ?? "",
            partOfSpeech: partial.partOfSpeech,
            transcription: partial.transcription,
            definition: partial.definition,
            translation: partial.translation,
            examples: partial.examples ?? []
        )
    }


}



extension PhraseCardContent {


    init(partial: PartiallyGenerated) {
        self.init(
            text: partial.text ?? "",
            meaning: partial.meaning,
            translation: partial.translation,
            examples: partial.examples ?? []
        )
    }


}



extension CollocationCardContent {


    init(partial: PartiallyGenerated) {
        self.init(
            pattern: partial.pattern ?? "",
            meaning: partial.meaning,
            translation: partial.translation,
            examples: partial.examples ?? []
        )
    }


}



extension IdiomCardContent {


    init(partial: PartiallyGenerated) {
        self.init(
            text: partial.text ?? "",
            figurativeMeaning: partial.figurativeMeaning ?? "",
            literalMeaning: partial.literalMeaning,
            translation: partial.translation,
            examples: partial.examples ?? []
        )
    }


}



extension RuleCardContent {


    init(partial: PartiallyGenerated) {
        self.init(
            title: partial.title ?? "",
            statement: partial.statement ?? "",
            examples: partial.examples ?? []
        )
    }


}
