#if DEBUG

import Foundation



extension WordCardContent {


    static let preview = WordCardContent(
        term: "serendipity",
        partOfSpeech: "noun",
        transcription: "/ˌser.ənˈdɪp.ə.ti/",
        definition: "the fact of finding pleasant things by chance",
        translation: nil,
        examples: ["They met by pure serendipity."]
    )


}



extension PhraseCardContent {


    static let preview = PhraseCardContent(
        text: "on the same page",
        meaning: "in agreement; sharing the same understanding",
        translation: nil,
        examples: ["Let's make sure we're on the same page."]
    )


}



extension CollocationCardContent {


    static let preview = CollocationCardContent(
        pattern: "heavy rain",
        meaning: "a large amount of rain",
        translation: "сильный дождь",
        examples: ["Heavy rain is expected this weekend."]
    )


}



extension IdiomCardContent {


    static let preview = IdiomCardContent(
        text: "bite the bullet",
        figurativeMeaning: "to force yourself to do something unpleasant",
        literalMeaning: nil,
        translation: nil,
        examples: ["I finally bit the bullet and booked the dentist."]
    )


}



extension RuleCardContent {


    static let preview = RuleCardContent(
        title: "A vs. an",
        statement: "Use 'a' before a consonant sound and 'an' before a vowel sound.",
        examples: ["a university", "an hour", "an apple"]
    )


}

#endif
