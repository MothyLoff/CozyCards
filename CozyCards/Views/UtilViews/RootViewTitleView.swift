import SwiftUI



struct RootViewTitleView: View {


    @Binding var page: Page


    var body: some View {
        Text(page.rawValue.capitalized)
            .contentTransition(.opacity)
            .animation(.smooth, value: page)
    }
    
    
}



#Preview {


    RootView()
        .preferredColorScheme(.dark)


}
