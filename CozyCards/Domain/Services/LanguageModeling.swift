import Foundation
import FoundationModels



/// Access to the on-device language model, behind a protocol so screens and
/// stores never touch `LanguageModelSession` directly - and so the model can be
/// swapped for a mock in previews and tests.
///
/// The protocol is a factory, not a generator. A session is stateful and owns a
/// transcript, and this app scopes one session to one chat thread; making the
/// service generate directly would either leak that scoping into every call
/// site or force a single global context. So the service reports availability
/// and hands out one `ChatSessioning` per thread.
///
/// Always check `availability` before opening a session. On an ineligible
/// device there is no Private Cloud Compute fallback, so any state other than
/// `.available` is terminal for generation.
protocol LanguageModeling: Sendable {


    var availability: ModelAvailability { get }

    /// A session scoped to one chat thread. Pass the transcript persisted for
    /// that thread to resume with real model context; pass `nil` for a fresh
    /// conversation.
    func makeSession(restoring transcript: Data?) -> any ChatSessioning


}



/// One chat thread's conversation with the model.
///
/// A turn is not "text" or "card" - it is a sequence of both. The model answers
/// in prose and, when the question is about a word, a phrase, a collocation, an
/// idiom or a rule, it calls a tool that produces a structured card. So
/// `respond(to:)` streams `TurnEvent`s rather than a string.
///
/// Text arrives as growing snapshots; cards arrive whole. A card cannot arrive
/// any other way: a tool's arguments are delivered to the tool, never to the
/// caller, and the framework does not surface partially generated arguments.
/// That is why a `CardDraft` is born saved and has no streaming state.
///
/// `nonisolated` is load-bearing. This target builds with
/// `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, which puts every unannotated
/// declaration - protocols included - on the main actor. Without this keyword a
/// conforming session inherits that isolation, and `respond(to:)` runs the
/// entire inference loop on the main thread: SwiftUI never gets to draw the
/// prompt bubble, let alone the streaming reply. Generation belongs off the
/// main actor. Only the delivery of a `TurnEvent` hops back, and `ChatStore`
/// does that by being `@MainActor` itself.
nonisolated protocol ChatSessioning: AnyObject, Sendable {


    /// Loads model resources ahead of the first request to cut first-token latency.
    func prewarm()

    /// Streams one turn. The stream finishes when the model stops speaking.
    func respond(to prompt: String) -> AsyncThrowingStream<TurnEvent, Error>

    /// The session's transcript, encoded for storage. `nil` when it cannot be
    /// encoded - a thread that fails to persist its transcript still works, it
    /// just reopens without model context.
    func encodedTranscript() -> Data?

    /// Throws away the current context and starts over inside the same thread.
    /// The documented recovery from an exhausted context window.
    func reset()


}



/// Why a turn ended badly.
///
/// The framework's own errors are a `FoundationModels` type, and letting them
/// reach `ChatStore` would drag the framework into the presentation layer for
/// nothing. `ChatSessioning` implementations translate; everyone above reads
/// this.
enum GenerationFailure: Error, Equatable, Sendable {


    /// The prompt or the answer tripped the model's safety guardrail.
    case guardrailViolation

    /// The thread outgrew the model's context window. Recoverable only by
    /// throwing the context away: call `ChatSessioning.reset()`.
    case contextWindowExceeded

    case cancelled

    case other(String)


}



/// Something the model produced during one turn.
enum TurnEvent: Sendable {


    /// The reply so far. Each event carries the whole text, not a delta.
    case text(String)

    /// A finished card, produced by a tool call.
    case card(Card)


}



/// Whether the on-device model can be used right now.
///
/// Mirrors `SystemLanguageModel.Availability`. There is no Private Cloud Compute
/// fallback, so anything other than `.available` means generation is unavailable
/// and the UI should say so rather than wait. The three unavailable reasons ask
/// for three different answers: `.deviceNotEligible` is permanent and the feature
/// should be hidden, `.appleIntelligenceNotEnabled` is the user's own setting and
/// worth one prompt, `.modelNotReady` is temporary and worth a retry.
enum ModelAvailability: Equatable, Sendable {


    case available

    case deviceNotEligible

    case appleIntelligenceNotEnabled

    case modelNotReady

    /// A reason this build does not know about yet.
    case unavailable


}
