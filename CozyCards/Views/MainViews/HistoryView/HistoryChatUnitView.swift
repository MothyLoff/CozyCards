import SwiftUI



struct HistoryChatUnitView: View {
    var chatName: String
    
    @Binding var page : Page
    
    var body: some View {
        
        Button {
            withAnimation(.spring(duration: 0.2)) {
                page = .chat
            }
        } label: {
            Text(chatName)
                .lineLimit(1)
        }
        .padding(.horizontal)
        .buttonStyle(.plain)
        
    }
}
