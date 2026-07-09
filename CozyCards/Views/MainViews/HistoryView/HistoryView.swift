import SwiftUI

struct Chat {
    let id: UUID = UUID()
    var wordHighlights: [String]
}

struct HistoryView: View {
    let chats : [Chat] = [
        Chat(wordHighlights: ["serendipity", "quintessential","epistemology", "incomprehensible"]),
        Chat(wordHighlights: ["lolol", "quintessential","epistemology", "incomprehensible"]),
        Chat(wordHighlights: ["serendipity", "quintessential","epistemology", "incomprehensible"]),
        Chat(wordHighlights: ["serendipity", "quintessential","epistemology", "incomprehensible"]),
    ]
    
    @Binding var page: Page
    @State var chatsSearch: String = ""
    
    @Namespace private var footerNamespace
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Recent chats")
                    .font(.title)
//                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                
                ForEach(chats, id:\.self.id) { chat in
                    let chatName = chat.wordHighlights.joined(separator: ", ")
                    
                    if chatsSearch == "" || chatName.localizedCaseInsensitiveContains(chatsSearch) {
                        HistoryChatUnitView(chatName: chatName, page: $page)
                            .padding(.vertical, 6)
                        Divider()
                    }
                    
                    
                }
            }
        }
        .defaultScrollAnchor(.top)
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom) {
            GlassEffectContainer {
                HStack {
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        
                        TextField("Search in chats..", text: $chatsSearch)
                    }
                    .padding()
                    .glassEffect(.regular.interactive())
                    .glassEffectID("search", in: footerNamespace)
                    
                    Button {
                        withAnimation(.spring(duration: 0.2)) {
                            page = .chat
                        }
                    } label: {
                        Image(systemName: "pencil")
                            .padding()
                            
                    }
                    .glassEffect(.regular.interactive())
                    .glassEffectID("new", in: footerNamespace)
                    
                }
                .padding(.horizontal)
            }
            
        }
    }
    
    
}
