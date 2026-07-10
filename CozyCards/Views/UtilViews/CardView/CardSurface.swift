import SwiftUI



extension View {


    /// The shared card background: padding plus a rounded surface.
    func cardSurface() -> some View {
        padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 32)
                    .foregroundStyle(.background.secondary)
            }
    }


}
