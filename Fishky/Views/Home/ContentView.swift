import SwiftUI
import SwiftData

// MARK: ContentView

struct ContentView: View {
    @Environment(\.openWindow) var openWindow 
    @Environment(\.modelContext) private var modelContext
    @State var currentDeck: Deck?
    
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.doubleColumn)) {
            DeckListView(currentDeck: $currentDeck)
                .navigationTitle("Fishky")
        } detail: {
            if let currentDeck {
                DeckView(currentDeck)
            } else {
                Text("Select or create a deck")
            }
        }
    }
}



// MARK: PREVIEW

#Preview(traits: .sampleData) {
    ContentView()
//        .modelContainer(previewContainer)
}
#Preview("empty") {
    ContentView()
}
