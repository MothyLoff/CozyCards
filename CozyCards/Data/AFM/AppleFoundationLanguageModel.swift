import Foundation
import FoundationModels
import os



private let logger = Logger(subsystem: "CozyCards", category: "AFM")



/// `LanguageModeling` on top of Apple's on-device model.
///
/// Holds no session of its own: sessions belong to threads, and this type only
/// answers "can we generate at all" and hands out new ones.
struct AppleFoundationLanguageModel: LanguageModeling {


    private let model = SystemLanguageModel.default


    var availability: ModelAvailability {
        switch model.availability {
        case .available:
            .available

        case .unavailable(.deviceNotEligible):
            .deviceNotEligible

        case .unavailable(.appleIntelligenceNotEnabled):
            .appleIntelligenceNotEnabled

        case .unavailable(.modelNotReady):
            .modelNotReady

        // The framework may grow reasons this build has never heard of. Treat
        // them as unavailable rather than as available-by-accident.
        @unknown default:
            .unavailable
        }
    }


    func makeSession(restoring transcript: Data?) -> any ChatSessioning {
        AFMChatSession(restoring: transcript)
    }


}



/// One thread's `LanguageModelSession`, plus the tool that turns a question
/// into a card.
///
/// The session is recreated - not mutated - on `reset()`, because a
/// `LanguageModelSession` cannot forget. Recreating on an exhausted context
/// window is the framework's documented recovery.
///
/// `nonisolated`: under this target's `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`
/// an unannotated class lands on the main actor, and the whole `streamResponse`
/// loop - plus the tool call it drives - would run there. Inference is not main
/// thread work. `@unchecked Sendable` glosses over the isolation check; it does
/// not move the work.
///
/// `@unchecked Sendable`: every mutable member is touched only from `respond`,
/// `reset` and `encodedTranscript`, and `ChatStore` calls all three from the
/// main actor. The type exists to be owned by exactly one thread's store.
nonisolated final class AFMChatSession: ChatSessioning, @unchecked Sendable {


    private let tool = CreateCardTool()

    private var session: LanguageModelSession


    init(restoring transcript: Data?) {
        session = Self.makeSession(tool: tool, transcript: transcript)
    }


    func prewarm() {
        session.prewarm()
    }


    /// Bridges two sources into one stream: the text snapshots the framework
    /// hands back, and the cards the tool receives while that text is being
    /// produced. The tool fires from inside `streamResponse`, so both land on
    /// the same continuation in the order the model produced them.
    func respond(to prompt: String) -> AsyncThrowingStream<TurnEvent, Error> {
        AsyncThrowingStream { continuation in
            tool.emit = { card in
                continuation.yield(.card(card))
            }

            let task = Task {
                do {
                    for try await partial in session.streamResponse(to: prompt) {
                        continuation.yield(.text(partial.content))
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: Self.failure(for: error))
                }
            }

            continuation.onTermination = { [tool] _ in
                task.cancel()
                tool.emit = nil
            }
        }
    }


    func encodedTranscript() -> Data? {
        try? JSONEncoder().encode(session.transcript)
    }


    func reset() {
        session = Self.makeSession(tool: tool, transcript: nil)
    }


    /// Translates the framework's errors into the domain's. Everything the app
    /// reacts to differently gets its own case; the rest collapses into `.other`
    /// rather than being swallowed.
    ///
    /// A turn can fail in two places, and the framework reports them as two
    /// unrelated types. Generation itself throws `GenerationError`. A failure
    /// while the model is filling a tool's arguments - a tripped guardrail, a
    /// schema the model could not satisfy - throws `ToolCallError`, which wraps
    /// the real cause in `underlyingError`. Casting to `GenerationError` alone
    /// misses every one of those and reports "something went wrong" for a
    /// guardrail violation the app knows exactly how to describe.
    private static func failure(for error: Error) -> GenerationFailure {
        if error is CancellationError { return .cancelled }

        if let toolCallError = error as? LanguageModelSession.ToolCallError {
            logger.error("Tool \(toolCallError.tool.name, privacy: .public) failed")
            return failure(for: toolCallError.underlyingError)
        }

        switch error as? LanguageModelSession.GenerationError {
        case .guardrailViolation:
            return .guardrailViolation
        case .exceededContextWindowSize:
            return .contextWindowExceeded
        default:
            // `localizedDescription` on these errors is a one-liner that
            // routinely says nothing. The framework puts the useful part in
            // `failureReason`. The UI still gets a sentence a person can read;
            // the console gets the truth.
            logger.error("Generation failed: \(String(describing: error), privacy: .public)")
            if let generationError = error as? LanguageModelSession.GenerationError {
                logger.error("Reason: \(generationError.failureReason ?? "none", privacy: .public)")
            }
            return .other(error.localizedDescription)
        }
    }


    /// A restored transcript already carries the instructions it was created
    /// with, so they are passed only when starting fresh. Passing both would
    /// state them twice.
    private static func makeSession(tool: CreateCardTool, transcript: Data?) -> LanguageModelSession {
        if let transcript, let decoded = try? JSONDecoder().decode(Transcript.self, from: transcript) {
            return LanguageModelSession(tools: [tool], transcript: decoded)
        }

        return LanguageModelSession(tools: [tool]) {
            ChatInstructions.text
        }
    }


}
