import SwiftUI

// changes from list to grid depending on screen size class. made for FlashcardListView
struct AdaptiveList<Content: View>: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @ViewBuilder var content: Content
    
    let columns = [GridItem(.adaptive(minimum: 250, maximum: 350))]
    
    var body: some View {
        if horizontalSizeClass == .compact {
            LazyVStack {
                ForEach(subviews: content) { view in
                    view
                }
            }
        } else {
            LazyVGrid(columns: columns) {
                ForEach(subviews: content) { view in
                    view
                }
            }
        }
    }
    
}
