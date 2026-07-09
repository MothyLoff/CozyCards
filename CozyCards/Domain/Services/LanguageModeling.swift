import FoundationModels



/// Access to the on-device language model, behind a protocol so screens and
/// view models never touch `LanguageModelSession` directly - and so the model
/// can be swapped for a mock in previews and tests.
///
/// Always check `availability` before requesting generation. On an ineligible
/// device there is no Private Cloud Compute fallback, so any state other than
/// `.available` is terminal for generation.
protocol LanguageModeling {


    var availability: ModelAvailability { get }

    /// Streams a structured card for `query`. Each snapshot is an incrementally
    /// filled card; the final snapshot is complete.
    func streamCard(for query: String) -> AsyncThrowingStream<Card.PartiallyGenerated, Error>

    /// Streams a free-text answer for `prompt`, each snapshot a growing string.
    func streamText(for prompt: String) -> AsyncThrowingStream<String, Error>

    /// A short title summarizing a thread, used to label chat history.
    func suggestTitle(for thread: ChatThread) async throws -> String

    /// Loads model resources ahead of the first request to cut first-token latency.
    func prewarm()


}



/// Whether the on-device model can be used right now.
///
/// Mirrors `SystemLanguageModel.availability`. There is no Private Cloud Compute
/// fallback, so anything other than `.available` means generation is unavailable
/// and the UI should say so rather than wait.
enum ModelAvailability: Equatable, Sendable {


    case available

    case deviceNotEligible

    case appleIntelligenceNotEnabled

    case modelNotReady

    case unavailable


}
