//
//  ContentView.swift
//  CozyCards
//
//  Created by Тимофей Фролов on 06.07.2026.
//

import SwiftUI



enum Page: String {
    
    
    case chat, chats, library
    
    
}



struct RootView: View {
    
    
    @State private var page: Page = .chat
    
    
    var body: some View {
        TabView(selection: $page) {
            ChatsView()
                .tag(Page.chats)
            ChatView()
                .tag(Page.chat)
            LibraryView()
                .tag(Page.library)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .safeAreaInset(edge: .top) {
            RootViewTitleView(page: $page)
        }
    }
    
    
}



#Preview {
    
    
    RootView()
    
    
}
