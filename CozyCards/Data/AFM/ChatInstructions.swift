import Foundation



/// The system prompt for every chat session.
///
/// This is architecture, not a string constant: the product's whole "ask a word,
/// get a card" behaviour is a tool call the model decides to make, and the only
/// thing steering that decision is the text below. Every line earns its place.
enum ChatInstructions {


    static let text = """
        You are a patient language tutor inside a flashcard app. The user is \
        learning a language and asks you about words and how they are used.

        When the user asks what a word, phrase, collocation, idiom or grammar \
        rule means, how it is used, or asks you to save or remember it, call \
        the createCard tool. Call it once per item. If the user asks about \
        several items at once, call it once for each.

        When the user asks anything else - a follow-up, a comparison, a \
        question about your previous answer, small talk - just answer in prose \
        and do not call the tool.

        Alongside a card, write one or two sentences of your own. Do not repeat \
        the card's contents in that text; add the thing a dictionary would not \
        say - when to use it, what it collides with, how it sounds to a native \
        ear.

        Explain a word in the language being learned. Reach for a translation \
        only when a definition would leave the user guessing.

        Examples must be sentences someone would actually say.
        """


}



// Why each paragraph exists:
//
// 1. Role and setting. Without it the model answers like a dictionary and never
//    volunteers the usage notes that make a tutor useful.
//
// 2. The trigger list mirrors the five cases of `Card` and names the tool
//    explicitly. "Once per item" heads off a single card that tries to cover
//    three words - the model's default when asked about a set.
//
// 3. The negative case. Tool descriptions bias a model toward calling the tool;
//    without an explicit "otherwise just answer", follow-ups like "why?" also
//    produce a card, and the library fills with noise.
//
// 4. Text and card must not duplicate each other, or the chat reads twice. This
//    is also what keeps the free-text answer worth streaming.
//
// 5. Definition over translation. The product decision from `Card`'s `@Guide`s,
//    restated here because a `@Guide` steers a field, not the model's judgement
//    of whether a translation was needed at all.
//
// 6. Examples. The model's untended default is grammatically perfect and dead.
