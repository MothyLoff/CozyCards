import Foundation
import Observation



/// Screen-facing state for chat. Owns the model session for the active thread,
/// forwards persistence to `ChatRepository`/`ChatTranscriptStoring`, and saves
/// the cards a turn produces into the library.
///
/// There is always a `currentThread` - the one `ChatView` renders - together
/// with a session scoped to it. Opening a different thread rebuilds the session
/// from that thread's saved transcript, so follow-up questions have real model
/// context; starting a new thread gets a session with no history at all.
///
/// The store, not the tool, writes to the library. Saving a card is a decision
/// about the user's data, and it belongs where the undo lives.
@Observable
@MainActor
final class ChatStore {


    private(set) var threads: [ChatThread] = []
    private(set) var currentThread: ChatThread

    var availability: ModelAvailability { language.availability }


    private let repository: any ChatRepository & ChatTranscriptStoring
    private let library: any LibraryRepository
    private let language: any LanguageModeling

    private var session: any ChatSessioning


    init(
        repository: any ChatRepository & ChatTranscriptStoring,
        library: any LibraryRepository,
        language: any LanguageModeling
    ) {
        self.repository = repository
        self.library = library
        self.language = language

        currentThread = ChatThread()
        session = language.makeSession(restoring: nil)

        observe()
    }


    /// Call when the chat screen appears: loads model resources before the
    /// first prompt and cuts the wait for the first token.
    func prewarm() {
        guard language.availability == .available else { return }
        session.prewarm()
    }


    /// Starts a fresh conversation with no carried-over model context.
    func startNewThread() {
        currentThread = ChatThread()
        session = language.makeSession(restoring: nil)
    }


    /// Switches the active conversation and rebuilds its session from the saved
    /// transcript, if there is one.
    func open(_ thread: ChatThread) async {
        currentThread = thread
        let transcript = await repository.loadTranscript(for: thread.id)
        session = language.makeSession(restoring: transcript)
    }


    func rename(id: UUID, to title: String) {
        Task { await repository.rename(id: id, to: title) }
    }


    func remove(id: UUID) {
        if currentThread.id == id {
            startNewThread()
        }
        Task { await repository.remove(id: id) }
    }


    /// Sends `prompt` in the current thread, streaming the reply into a new
    /// `ChatMessage`, then persisting the thread and its updated transcript.
    ///
    /// A card arrives already finished, so its draft is born `.completed`: the
    /// model hands a card to the tool, and the tool only ever sees the whole
    /// thing.
    func send(prompt: String) async {
        guard language.availability == .available else { return }

        let message = ChatMessage(prompt: prompt)
        currentThread.messages.append(message)

        let isFirstMessage = currentThread.messages.count == 1
        if currentThread.title.isEmpty {
            currentThread.title = prompt
        }

        do {
            for try await event in session.respond(to: prompt) {
                switch event {
                case .text(let text):
                    message.text = text

                case .card(let card):
                    let draft = CardDraft(card: card, state: .completed)
                    message.cards.append(draft)
                    await save(draft, from: message)
                }
            }
            message.state = .completed
        } catch {
            let failure = error as? GenerationFailure ?? .other(error.localizedDescription)
            message.state = .failed(Self.reason(for: failure))

            // A context window can only be recovered by throwing it away, per
            // Apple's guidance. This turn is lost; the thread keeps working.
            if failure == .contextWindowExceeded {
                session.reset()
            }
        }

        if isFirstMessage {
            await repository.add(currentThread)
        } else {
            await repository.save(currentThread)
        }

        if let transcriptData = session.encodedTranscript() {
            await repository.saveTranscript(transcriptData, for: currentThread.id)
        }
    }


    /// Takes back the automatic save: the library item goes, the draft stays in
    /// the transcript marked `.discarded`.
    ///
    /// The model is not told. Its tool returned "saved", and it still believes
    /// that. Harmless within one turn, misleading across several - the fix is a
    /// second tool the UI can call, and it is not built yet.
    func discard(_ draft: CardDraft) {
        guard let itemID = draft.libraryItemID else { return }

        draft.libraryItemID = nil
        draft.state = .discarded
        Task { await library.remove(id: itemID) }
    }


    private func save(_ draft: CardDraft, from message: ChatMessage) async {
        guard let card = draft.card else { return }

        // Tags belong to the user; the model never invents them.
        let item = LibraryItem(card: card, tags: [], sourceMessageID: message.id)
        draft.libraryItemID = item.id
        await library.add(item)
    }


    private func observe() {
        Task { [weak self] in
            guard let stream = await self?.repository.observe() else { return }
            for await snapshot in stream {
                self?.threads = snapshot
            }
        }
    }


    /// Something a person can read. A guardrail violation's `localizedDescription`
    /// says nothing useful, and a failed turn is the one moment the user needs
    /// to know what happened.
    private static func reason(for failure: GenerationFailure) -> String {
        switch failure {
        case .guardrailViolation: "I can't help with that one."
        case .contextWindowExceeded: "This conversation got too long for the model to continue."
        case .cancelled: "Cancelled."
        case .other: "Something went wrong. Try again."
        }
    }


}
