import SwiftUI



struct RootViewTitleView: View {


    @Binding var page: Page
    var progress: CGFloat

    private let pages = Page.allCases

    @State private var frames: [Int: CGRect] = [:]

    private var clampedProgress: CGFloat {
        min(max(progress, 0), CGFloat(pages.count - 1))
    }


    var body: some View {
        HStack(spacing: 28) {
            ForEach(Array(pages.enumerated()), id: \.element) { index, item in
                let distance = min(abs(clampedProgress - CGFloat(index)), 1)

                Text(item.rawValue.capitalized)
                    .font(.headline)
                    .opacity(0.4 + 0.6 * (1 - distance))
                    .scaleEffect(1 + 0.06 * (1 - distance))
                    .onGeometryChange(for: CGRect.self) { proxy in
                        proxy.frame(in: .named("titlebar"))
                    } action: { frames[index] = $0 }
                    .contentShape(.rect)
                    .onTapGesture {
                        withAnimation(.spring(duration: 0.25)) { page = item }
                    }
            }
        }
        .overlay(alignment: .bottomLeading) { indicator }
        .coordinateSpace(.named("titlebar"))
        .padding(.top, 4)
        .padding(.bottom, 8)
    }


    @ViewBuilder
    private var indicator: some View {
        let lower = min(Int(clampedProgress), pages.count - 1)
        let upper = min(lower + 1, pages.count - 1)
        let t = clampedProgress - CGFloat(lower)

        if let a = frames[lower], let b = frames[upper] {
            let x = a.minX + (b.minX - a.minX) * t
            let width = a.width + (b.width - a.width) * t

            Capsule()
                .fill(.primary)
                .frame(width: width, height: 2)
                .offset(x: x, y: 4)
        }
    }


}







#Preview {


    RootView()
        .preferredColorScheme(.dark)


}
