import SwiftUI
import SwiftData

struct DeckListItem: View {
    var deck: Deck
    
    var body: some View {
        NavigationLink(value: deck) {
            if deck.name.isEmpty {
                HStack {
                    Text("Untitled deck").italic().foregroundColor(.gray)
                }
            } else {
                HStack {
                    Text(deck.name)
                }
            }
        }
    }
}


#Preview(traits: .sampleData) {
    @Previewable @Query var decks: [Deck]
    List {
        DeckListItem(deck: decks.first!)
    }
}
