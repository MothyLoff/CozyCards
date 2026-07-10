import SwiftUI



/// The library as one flat list of every saved card.
///
/// A card shows here no matter its kind or tags, so a card auto-saved from chat
/// - which has no tags yet - is visible the moment it lands. Filtering is a lens
/// over that list, never a structure: free text narrows by headword or tag, the
/// kind chips narrow by `CardKind`, the tag chips narrow by membership. Every
/// piece of state lives in `LibraryStore`; this view owns none of it and never
/// touches SwiftData or `@Query`.
struct LibraryView: View {


    @Environment(LibraryStore.self) private var store

    @State private var editingItem: LibraryItem?
    @State private var isCreatingItem = false


    var body: some View {
        @Bindable var store = store

        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(store.filtered) { item in
                    Button {
                        editingItem = item
                    } label: {
                        CompactCardView(card: item.card)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
        .overlay {
            if store.filtered.isEmpty {
                emptyState
            }
        }
        .safeAreaInset(edge: .top) {
            LibraryFilterBar(
                query: $store.query,
                kinds: $store.kinds,
                selectedTags: $store.tags,
                allTags: store.allTags
            )
        }
        .safeAreaInset(edge: .bottom) {
            addButton
        }
        .sheet(item: $editingItem) { item in
            LibraryItemDetailsView(mode: .edit(item))
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isCreatingItem) {
            LibraryItemDetailsView(mode: .new)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }


    /// Two distinct empty states: a genuinely empty library reads differently
    /// from a full one that the current filter has narrowed to nothing.
    private var emptyState: some View {
        ContentUnavailableView {
            Label(
                store.items.isEmpty ? "No cards yet" : "No matches",
                systemImage: store.items.isEmpty ? "tray" : "line.3.horizontal.decrease.circle"
            )
        } description: {
            Text(
                store.items.isEmpty
                    ? "Cards you save from chat show up here."
                    : "Try a different search or clear the filters."
            )
        }
    }

    private var addButton: some View {
        HStack {
            Spacer()
            Button {
                isCreatingItem = true
            } label: {
                Image(systemName: "plus")
                    .padding()
            }
            .glassEffect(.regular.interactive())
        }
        .padding(.horizontal)
    }


}



/// The pinned filter controls: a search field over a single chip row that holds
/// the kind filters and then, separated, the tag filters. Bindings point
/// straight at `LibraryStore`, so toggling a chip re-derives `store.filtered`
/// with no local mirror to keep in sync.
private struct LibraryFilterBar: View {


    @Binding var query: String
    @Binding var kinds: Set<CardKind>
    @Binding var selectedTags: Set<String>

    let allTags: [String]


    var body: some View {
        VStack(spacing: 8) {
            searchField

            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(CardKind.allCases, id: \.self) { kind in
                        FilterChip(title: kind.displayName, isOn: kinds.contains(kind)) {
                            toggle(kind, in: &kinds)
                        }
                    }

                    if !allTags.isEmpty {
                        Divider()
                            .frame(height: 20)

                        ForEach(allTags, id: \.self) { tag in
                            FilterChip(title: tag, isOn: selectedTags.contains(tag)) {
                                toggle(tag, in: &selectedTags)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.vertical, 8)
        .background(.bar)
    }


    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search", text: $query)

            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background {
            Capsule()
                .foregroundStyle(.background.secondary)
        }
        .padding(.horizontal)
    }

    /// Set membership toggle shared by the kind and tag chips.
    private func toggle<Element: Hashable>(_ element: Element, in set: inout Set<Element>) {
        if set.contains(element) {
            set.remove(element)
        } else {
            set.insert(element)
        }
    }


}



/// A single capsule chip that reads as selected or not.
struct FilterChip: View {


    let title: String
    let isOn: Bool
    let action: () -> Void


    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .foregroundStyle(isOn ? AnyShapeStyle(.white) : AnyShapeStyle(.primary))
                .background {
                    Capsule()
                        .foregroundStyle(isOn ? AnyShapeStyle(.tint) : AnyShapeStyle(.background.secondary))
                }
        }
        .buttonStyle(.plain)
    }


}



extension CardKind {


    /// A human-readable, plural label for filter chips and the kind picker.
    var displayName: String {
        switch self {
        case .word: "Words"
        case .phrase: "Phrases"
        case .collocation: "Collocations"
        case .idiom: "Idioms"
        case .rule: "Rules"
        }
    }


}



#Preview {

    LibraryView()
        .environment(
            LibraryStore(
                repository: InMemoryLibraryRepository(
                    items: [
                        LibraryItem(card: .word(.preview), tags: ["favorites"]),
                        LibraryItem(card: .idiom(.preview), tags: ["figurative"]),
                        LibraryItem(card: .rule(.preview)),
                        LibraryItem(card: .collocation(.preview), tags: ["favorites"]),
                    ]
                )
            )
        )

}
