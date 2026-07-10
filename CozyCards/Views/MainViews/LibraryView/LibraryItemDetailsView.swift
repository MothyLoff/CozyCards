import SwiftUI



/// The full editor for one library card.
///
/// It is a thin shell around `CardView`: that view already renders and edits all
/// five kinds, so this one only adds identity-preserving save, delete, and a tag
/// editor. Editing keeps the card's kind fixed - switching kind would strand the
/// fields the user already filled - while a brand-new card lets the user pick the
/// kind up front. The save action lives in a bottom `safeAreaInset` so it stays
/// reachable no matter how tall a fully filled card grows.
struct LibraryItemDetailsView: View {


    enum Mode {

        case new

        case edit(LibraryItem)

    }


    @Environment(\.dismiss) private var dismiss
    @Environment(LibraryStore.self) private var store

    private let mode: Mode

    /// Identity kept out of the draft: it is not content and must survive a save
    /// untouched, so it is captured once at init and never bound to a field.
    private let itemID: UUID
    private let createdAt: Date
    private let sourceMessageID: UUID?

    @State private var draft: Card
    @State private var tags: [String]
    @State private var newTag: String = ""


    init(mode: Mode) {
        self.mode = mode

        switch mode {
        case .new:
            itemID = UUID()
            createdAt = .now
            sourceMessageID = nil
            _draft = State(initialValue: .empty(.word))
            _tags = State(initialValue: [])

        case .edit(let item):
            itemID = item.id
            createdAt = item.createdAt
            sourceMessageID = item.sourceMessageID
            _draft = State(initialValue: item.card)
            _tags = State(initialValue: item.tags)
        }
    }


    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if isNew {
                    kindPicker
                }

                CardView(card: $draft)

                TagEditorView(tags: $tags, draft: $newTag)
            }
            .padding()
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .top) {
            header
        }
        .safeAreaInset(edge: .bottom) {
            saveButton
        }
    }


    /// Floats over the scrolling card instead of sitting on a bar. `.bar` is a
    /// material, and a material laid over a plain sheet background reads as a
    /// second surface with a seam across it - which is exactly what it looked
    /// like. Glass has no seam: it tints itself from whatever scrolls beneath.
    ///
    /// Both actions are icons in circles rather than a word and an icon, so the
    /// destructive one can carry a red tint without shouting across the header.
    private var header: some View {
        GlassEffectContainer(spacing: 16) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .frame(width: 22, height: 22)
                        .padding(12)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: .circle)

                Spacer()

                if !isNew {
                    Button(role: .destructive) {
                        store.remove(id: itemID)
                        dismiss()
                    } label: {
                        Image(systemName: "trash")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(width: 22, height: 22)
                            .padding(12)
                    }
                    .buttonStyle(.plain)
                    .glassEffect(.regular.tint(.red).interactive(), in: .circle)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    /// New cards only: pick the kind before filling it in. Switching kind rebuilds
    /// the draft as an empty card of that kind, which is safe because there is
    /// nothing to lose yet.
    private var kindPicker: some View {
        Picker("Kind", selection: kindBinding) {
            ForEach(CardKind.allCases, id: \.self) { kind in
                Text(kind.displayName).tag(kind)
            }
        }
        .pickerStyle(.segmented)
    }

    private var saveButton: some View {
        Button {
            save()
        } label: {
            Text(isNew ? "Add to library" : "Save changes")
                .frame(maxWidth: .infinity)
                .padding()
        }
        .glassEffect(.regular.interactive())
        .disabled(draft.primaryText.trimmingCharacters(in: .whitespaces).isEmpty)
        .padding()
    }


    private var isNew: Bool {
        if case .new = mode { return true }
        return false
    }

    private var kindBinding: Binding<CardKind> {
        Binding(
            get: { draft.kind },
            set: { draft = .empty($0) }
        )
    }

    private func save() {
        let item = LibraryItem(
            id: itemID,
            card: draft,
            tags: tags,
            createdAt: createdAt,
            sourceMessageID: sourceMessageID
        )

        if isNew {
            store.add(item)
        } else {
            store.updateItem(item)
        }
        dismiss()
    }


}



/// Adds and removes the freeform tags on a card.
///
/// Tags are the only structure the library keeps, so this is the one place a
/// user creates them: type a name and commit, tap a chip's cross to drop it.
/// Duplicates are folded case-insensitively so the filter chips stay clean.
private struct TagEditorView: View {


    @Binding var tags: [String]
    @Binding var draft: String


    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tags")
                .font(.headline)

            if !tags.isEmpty {
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(tags, id: \.self) { tag in
                            tagChip(tag)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }

            HStack(spacing: 8) {
                TextField("Add a tag", text: $draft)
                    .onSubmit(commit)

                Button(action: commit) {
                    Image(systemName: "plus.circle.fill")
                }
                .buttonStyle(.plain)
                .disabled(trimmedDraft.isEmpty)
            }
        }
        .cardSurface()
    }


    private func tagChip(_ tag: String) -> some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.subheadline)

            Button {
                tags.removeAll { $0 == tag }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background {
            Capsule()
                .foregroundStyle(.background.secondary)
        }
    }

    private var trimmedDraft: String {
        draft.trimmingCharacters(in: .whitespaces)
    }

    private func commit() {
        let tag = trimmedDraft
        draft = ""
        guard !tag.isEmpty else { return }
        guard !tags.contains(where: { $0.caseInsensitiveCompare(tag) == .orderedSame }) else { return }
        tags.append(tag)
    }


}



extension Card {


    /// An empty card of the given kind, for a manually created library entry.
    ///
    /// Every field starts blank; the editor fills them in. Kept in the library
    /// feature rather than the domain because it exists only to seed this form.
    static func empty(_ kind: CardKind) -> Card {
        switch kind {
        case .word:
            .word(WordCardContent(
                term: "", partOfSpeech: nil, transcription: nil,
                definition: nil, translation: nil, examples: []
            ))

        case .phrase:
            .phrase(PhraseCardContent(
                text: "", meaning: nil, translation: nil, examples: []
            ))

        case .collocation:
            .collocation(CollocationCardContent(
                pattern: "", meaning: nil, translation: nil, examples: []
            ))

        case .idiom:
            .idiom(IdiomCardContent(
                text: "", figurativeMeaning: "", literalMeaning: nil,
                translation: nil, examples: []
            ))

        case .rule:
            .rule(RuleCardContent(
                title: "", statement: "", examples: []
            ))
        }
    }


}



#Preview("Edit") {

    LibraryItemDetailsView(
        mode: .edit(LibraryItem(card: .idiom(.preview), tags: ["figurative", "favorites"]))
    )
    .environment(LibraryStore(repository: InMemoryLibraryRepository()))

}



#Preview("New") {

    LibraryItemDetailsView(mode: .new)
        .environment(LibraryStore(repository: InMemoryLibraryRepository()))

}
