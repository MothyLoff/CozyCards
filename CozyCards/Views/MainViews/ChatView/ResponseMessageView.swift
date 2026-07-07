import SwiftUI



struct ResponseMessageView : View {
    let response : String
    
    var body : some View {
        HStack {
            Text(response)
                .padding()
            Spacer()
        }
    }
}

#Preview {
    
    ResponseMessageView(response: "hihihiha")
    
}
