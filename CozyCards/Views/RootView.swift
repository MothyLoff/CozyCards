//
//  ContentView.swift
//  CozyCards
//
//  Created by Тимофей Фролов on 06.07.2026.
//

import SwiftUI



enum Page: String {
    
    
    case chat, swiper, library
    
    
}



struct RootView: View {
    
    
    @State private var page: Page = .chat
    
    
    var body: some View {
        TabView(selection: $page) {
            ChatView()
                .tag(Page.chat)
            SwiperView()
                .tag(Page.swiper)
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
