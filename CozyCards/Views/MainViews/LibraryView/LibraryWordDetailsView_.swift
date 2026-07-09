import SwiftUI



struct LibraryWordDetailsView_: View {

    enum Mode {
        case new(dictionaryName: String)
        case edit(LibraryItem)
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(LibraryStore.self) private var store

    private let mode: Mode
    private let existingID: UUID
    private let existingCreatedAt: Date
    private let existingSourceMessageID: UUID?
    private let existingTags: [String]

    @State private var term: String
    @State private var definition: String


    init(mode: Mode) {
        self.mode = mode

        let item: LibraryItem? = {
            if case .edit(let existing) = mode { return existing }
            return nil
        }()

        existingID = item?.id ?? UUID()
        existingCreatedAt = item?.createdAt ?? .now
        existingSourceMessageID = item?.sourceMessageID

        switch mode {
        case .new(let dictionaryName):
            existingTags = [dictionaryName]
        case .edit(let existing):
            existingTags = existing.tags
        }

        if case .word(let content) = item?.card {
            _term = State(initialValue: content.term)
            _definition = State(initialValue: content.definition ?? "")
        } else {
            _term = State(initialValue: "")
            _definition = State(initialValue: "")
        }
    }


    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.backward")
                            .padding()
                    }
                    .buttonStyle(.plain)
                    .glassEffect(.regular.interactive())

                    Spacer()

                    if case .edit = mode {
                        Button(role: .destructive) {
                            store.remove(id: existingID)
                            dismiss()
                        } label: {
                            Image(systemName: "trash")
                                .padding()
                        }
                        .buttonStyle(.plain)
                        .glassEffect(.regular.interactive())
                    }
                }

                TextField("Word", text: $term)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: true, vertical: false)
                    .lineLimit(1...2)
                    .font(.largeTitle)
                    .bold()
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 32)
                            .foregroundStyle(.background.secondary)
                    }
                    .padding(.bottom, 32)

                TextField("Type description here..", text: $definition, axis: .vertical)
                    .lineLimit(1...10)

                Button {
                    save()
                } label: {
                    Text(isNew ? "Add to library" : "Save changes")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .glassEffect(.regular.interactive())
                .disabled(term.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.top, 24)
            }
            .padding()
        }
    }


    private var isNew: Bool {
        if case .new(_) = mode { return true }
        return false
    }

    private func save() {
        let item = LibraryItem(
            id: existingID,
            card: .word(WordCardContent(
                term: term,
                partOfSpeech: nil,
                transcription: nil,
                definition: definition.isEmpty ? nil : definition,
                translation: nil,
                examples: []
            )),
            tags: existingTags,
            createdAt: existingCreatedAt,
            sourceMessageID: existingSourceMessageID
        )

        if isNew {
            store.add(item)
        } else {
            store.updateItem(item)
        }
        dismiss()
    }


}


#Preview {
    LibraryWordDetailsView_(mode: .new(dictionaryName: "Complicated words"))
        .environment(LibraryStore(repository: InMemoryLibraryRepository()))
}
