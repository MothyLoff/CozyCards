import Foundation
import FoundationModels



/// The tool the model calls when a question deserves a card.
///
/// The card is the tool's *arguments*, not its output: guided generation fills
/// a `Card` and hands it over, which is what makes the model - rather than a
/// classifier or a button - decide when a card exists at all.
///
/// The tool does not save anything. It forwards the card to whoever owns the
/// turn (`AFMChatSession` -> `ChatStore`) through `emit`, and returns a short
/// confirmation the model can keep talking around. Persistence, undo and the
/// link back to a `LibraryItem` are the store's business; a tool that wrote to
/// the library would put a side effect behind the model's judgement with no
/// place to undo it.
///
/// `@unchecked Sendable`: `emit` is set once, before the session starts a turn,
/// and read only from the tool call. The framework requires `Tool` to be
/// `Sendable` and there is nothing else mutable here.
///
/// `nonisolated` for the same reason `AFMChatSession` is: this target's default
/// actor isolation is `MainActor`, so without it `call(arguments:)` would hop to
/// the main thread in the middle of a turn.
nonisolated final class CreateCardTool: Tool, @unchecked Sendable {


    let name = "createCard"

    let description = """
        Creates a study card for a word, phrase, collocation, idiom or grammar \
        rule the user is asking about. Call this whenever the user asks what \
        something means, how it is used, or asks you to save or remember it.
        """


    /// Called with the finished card, on whatever executor the tool call runs on.
    var emit: (@Sendable (Card) -> Void)?


    /// The model fills a whole `Card` here. `Card` is a five-case tagged union,
    /// so choosing the case *is* choosing what kind of study material this is;
    /// the model cannot fill fields belonging to a case it did not pick.
    @Generable
    struct Arguments {


        @Guide(description: "The card to create. Pick the case that matches what the user asked about.")
        var card: Card


    }


    /// Returns a plain `String`. `ToolOutput` no longer exists - since the
    /// framework's beta 4 a tool returns any `PromptRepresentable`, and the
    /// value is inserted back into the transcript so the model can continue
    /// with it. The confirmation names the card so a follow-up question
    /// ("add an example to it") has something to refer to.
    func call(arguments: Arguments) async throws -> String {
        emit?(arguments.card)
        return "Created a \(arguments.card.kind.rawValue) card for \"\(arguments.card.primaryText)\" and saved it to the user's library."
    }


}
