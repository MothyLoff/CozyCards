//
//  CardView.swift
//  CozyCards
//
//  Created by Тимофей Фролов on 09.07.2026.
//

import SwiftUI



struct CardView: View {


    @Binding var card: Card


    var body: some View {
        switch card.kind {
        case .word:
            Text("word")
        default:
            Text("def")
        }
    }
}



#Preview {
    ScrollView {
        VStack(spacing: 16) {
            CardView(card: .constant(.word(WordCardContent(
                term: "serendipity",
                partOfSpeech: "noun",
                transcription: "/ˌser.ənˈdɪp.ə.ti/",
                definition: "the fact of finding pleasant things by chance",
                translation: nil,
                examples: ["They met by pure serendipity."]
            ))))

            CardView(card: .constant(.phrase(PhraseCardContent(
                text: "on the same page",
                meaning: "in agreement; sharing the same understanding",
                translation: nil,
                examples: ["Let's make sure we're on the same page."]
            ))))

            CardView(card: .constant(.collocation(CollocationCardContent(
                pattern: "heavy rain",
                meaning: "a large amount of rain",
                translation: "сильный дождь",
                examples: ["Heavy rain is expected this weekend."]
            ))))

            CardView(card: .constant(.idiom(IdiomCardContent(
                text: "bite the bullet",
                figurativeMeaning: "to force yourself to do something unpleasant",
                literalMeaning: nil,
                translation: nil,
                examples: ["I finally bit the bullet and booked the dentist."]
            ))))

            CardView(card: .constant(.rule(RuleCardContent(
                title: "A vs. an",
                statement: "Use 'a' before a consonant sound and 'an' before a vowel sound.",
                examples: ["a university", "an hour", "an apple"]
            ))))
        }
        .padding()
    }
}
