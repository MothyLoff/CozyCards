//
//  ContentView.swift
//  CozyCards
//
//  Created by Тимофей Фролов on 06.07.2026.
//

import SwiftUI
import SwiftData



enum Page: String, CaseIterable {


    case history, chat, library


}



struct RootView: View {


    @State private var page: Page = .chat
    @State private var position: Page? = .chat
    @State private var progress: CGFloat = 1

    private let pages = Page.allCases


    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(pages, id: \.self) { item in
                    view(for: item)
                        .containerRelativeFrame(.horizontal)
                        .id(item)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $position)
        .scrollIndicators(.hidden)
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            let width = geometry.containerSize.width
            return width > 0 ? geometry.contentOffset.x / width : progress
        } action: { _, newValue in
            progress = newValue
        }
        .onChange(of: position) { _, newValue in
            if let newValue, newValue != page { page = newValue }
        }
        .onChange(of: page) { _, newValue in
            if position != newValue {
                withAnimation(.spring(duration: 0.25)) { position = newValue }
            }
        }
        .safeAreaInset(edge: .top) {
            RootViewTitleView(page: $page, progress: progress)
        }
    }


    @ViewBuilder
    private func view(for item: Page) -> some View {
        switch item {
        case .history: HistoryView(page: $page)
        case .chat: ChatView(page: $page)
        case .library: LibraryView()
        }
    }


}



#Preview {


    let container = try! ModelContainer(
        for: LibraryItemModel.self,
        ChatThreadModel.self,
        ChatMessageModel.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let library = SwiftDataLibraryRepository(modelContainer: container)

    RootView()
        .environment(LibraryStore(repository: library))
        .environment(ChatStore(
            repository: SwiftDataChatRepository(modelContainer: container),
            library: library,
            language: MockLanguageModel()
        ))
        .modelContainer(container)


}
