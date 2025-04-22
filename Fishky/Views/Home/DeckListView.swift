import SwiftUI
import SwiftData

struct DeckListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow
    
    @Binding var currentDeck: Deck?
    @Query(sort: \Deck.timeUpdated, order: .reverse) var decks: [Deck]

    let deleteLabel = Label("Delete", systemImage: "trash")
    func deleteItemButton(_ deck: Deck) -> some View {
        Button(role: .destructive) {
            deleteItem(deck)
        } label: {
            deleteLabel
        }
    }

    var body: some View {
        List(selection: $currentDeck) {
            ForEach(decks) { deck in
                DeckListItem(deck: deck)
                    .contextMenu {
                        #if os(macOS)
                        Button {
                            openWindow(id: "deck", value: deck.id)
                        } label: {
                            Label("Open in new window", systemImage: "macwindow.on.rectangle")
                        }
                        #endif
                        deleteItemButton(deck)
                        
                    }
// TODO: double tap to open in new window
            }
            .onDelete { indexSet in
                deleteItems(offsets: indexSet)
            }
        }
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
#endif
            ToolbarItem(placement: .primaryAction) {
                Button(action: addDeck) {
                    Label("Create deck", systemImage: "plus")
                }
            }
        }
        .overlay {
            if decks.isEmpty {
                ContentUnavailableView {
                    Label("Create your first deck", systemImage: "text.document")
                } description: {
                    Text("New decks you create will appear here.")
                }
            }
        }
    }   
}

// MARK: STATE

extension DeckListView {
    private func addDeck() {
        withAnimation {
            let newDeck = Deck()
            modelContext.insert(newDeck)
            currentDeck = newDeck
            
            try? modelContext.save()
        }
    }
    
    private func deleteItem(_ item: Deck) {
        withAnimation {
            Deck.deleteItem(item)
            
            try? modelContext.save()
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            Deck.deleteItems(at: offsets, for: decks)
            
            try? modelContext.save()
        }
    }
}

#Preview(traits: .sampleData) {
    @Previewable @State var currentDeck: Deck?
    
    DeckListView(currentDeck: $currentDeck)
}
