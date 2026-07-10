import Foundation
import Observation
import FoundationModels



/// Screen-facing state for chat. Owns the model session for the active
/// thread and forwards persistence to `ChatRepository`/`ChatTranscriptStoring`,
/// mirroring how `LibraryStore` wraps `LibraryRepository`.
///
/// There's always a `currentThread` — the one `ChatView` renders, together
/// with a `LanguageModelSession` scoped to it. Opening a different thread
/// rebuilds the session from that thread's saved `Transcript`, so
/// follow-up questions inside a thread have real model context; starting a
/// new thread gets a session with no history at all.
@Observable
@MainActor
final class ChatStore {


    private(set) var threads: [ChatThread] = []
    private(set) var currentThread: ChatThread

    private let repository: any ChatRepository & ChatTranscriptStoring
    private var session: LanguageModelSession


    init(repository: any ChatRepository & ChatTranscriptStoring) {
        self.repository = repository
        currentThread = ChatThread()
        session = LanguageModelSession()
        observe()
    }


    /// Starts a fresh, empty conversation with no carried-over model context.
    func startNewThread() {
        currentThread = ChatThread()
        session = LanguageModelSession()
    }

    /// Switches the active conversation to an existing thread and rebuilds
    /// its model session from the saved transcript, if there is one.
    func open(_ thread: ChatThread) async {
        currentThread = thread

        if let data = await repository.loadTranscript(for: thread.id),
           let transcript = try? JSONDecoder().decode(Transcript.self, from: data) {
            session = LanguageModelSession(transcript: transcript)
        } else {
            session = LanguageModelSession()
        }
    }

    func rename(id: UUID, to title: String) {
        Task { await repository.rename(id: id, to: title) }
    }

    func remove(id: UUID) {
        if currentThread.id == id {
            currentThread = ChatThread()
            session = LanguageModelSession()
        }
        Task { await repository.remove(id: id) }
    }

    /// Sends `prompt` in the current thread, streaming the reply into a new
    /// `ChatMessage`, then persisting the thread and its updated transcript.
    func send(prompt: String) async {
        let message = ChatMessage(prompt: prompt)
        currentThread.messages.append(message)

        let isFirstMessage = currentThread.messages.count == 1
        if currentThread.title.isEmpty {
            currentThread.title = prompt
        }

        do {
            for try await partial in session.streamResponse(to: prompt) {
                message.text = partial.content
            }
            message.state = .completed
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
            // Recommended recovery per Apple's guidance: drop this session
            // and start a fresh one. This message fails, but the thread
            // keeps working for whatever comes next.
            message.state = .failed("This conversation got too long for the model to continue.")
            session = LanguageModelSession()
        } catch {
            message.state = .failed(error.localizedDescription)
        }

        if isFirstMessage {
            await repository.add(currentThread)
        } else {
            await repository.save(currentThread)
        }

        if let transcriptData = try? JSONEncoder().encode(session.transcript) {
            await repository.saveTranscript(transcriptData, for: currentThread.id)
        }
    }


    private func observe() {
        Task { [weak self] in
            guard let stream = await self?.repository.observe() else { return }
            for await snapshot in stream {
                self?.threads = snapshot
            }
        }
    }


}
