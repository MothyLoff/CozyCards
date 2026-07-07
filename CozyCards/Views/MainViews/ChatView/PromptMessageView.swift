import SwiftUI



struct PromptMessageView : View {
    let prompt : String
    
    var body : some View {
        HStack {
            Spacer()
            Text(prompt)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 32)
                        .foregroundStyle(.background.secondary)
                }
        }
        
    }
    
    
}

#Preview {
    
    PromptMessageView(prompt: "Id quasi eveniet fugiat nobis illum doloribus. Animi cumque quo recusandae quia quo distinctio iusto rem. Non nihil corrupti magni harum tenetur ut eveniet. Minus id eligendi consequatur. Amet earum eligendi excepturi.")
    
}
