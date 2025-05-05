import SwiftUI
import SwiftData

struct DeckListItem: View {
    var deck: Deck
    
    var percentageColor: Color {
        let percentage = deck.percentageComplete
        
        return if percentage < 0.2 {
            .red
        } else if percentage < 0.8 {
            .orange
        } else if percentage < 0.95 {
            .mint
        } else {
            .green
        }
    }
    
    var body: some View {
        NavigationLink(value: deck) {
            VStack(alignment: .leading) {
                if deck.name.isEmpty {
                    Text("Untitled deck").italic().foregroundColor(.gray)
                } else {
                    Text(deck.name)
                }
                HStack {
                    Text("\(Int(deck.percentageComplete * 100))% complete")
                        .foregroundStyle(percentageColor)
                }.textScale(.secondary)
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
