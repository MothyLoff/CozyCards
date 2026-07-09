import SwiftUI



struct LibraryWordDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State var word: String
    @State var description: String
    
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
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "trash")
                            .padding()
                        
                    }
                    .buttonStyle(.plain)
                    .glassEffect(.regular.interactive())
                }
                
                TextField("", text: $word)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: true, vertical: false)
                    .lineLimit(1...2)
                    .font(.largeTitle)
                    .bold()
                    .padding()
//                    .glassEffect(.regular.interactive())
                    .background {
                        RoundedRectangle(cornerRadius: 32)
                            .foregroundStyle(.background.secondary)
                    }

                    .padding(.bottom, 32)
                
                
                TextField("Type description here..", text: $description, axis: .vertical)
                    .lineLimit(1...10)
            }
            .padding()
        }
    }
}


#Preview {
    LibraryWordDetailsView(word: "Word", description: "Description")
}
