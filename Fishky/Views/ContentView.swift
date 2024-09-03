//
//  ContentView.swift
//  Fishky
//
//  Created by Filip Krawczyk on 18/06/2023.
//

import SwiftUI
import SwiftData

// -- MARK: ContentView

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Deck.timeUpdated, order: .reverse) var decks: [Deck]
    @State var currentDeck: Deck?
    let deleteLabel = Label("Delete", systemImage: "trash")
    
    func deleteItemButton(_ deck: Deck) -> some View {
        Button(role: .destructive) {
            deleteItem(deck)
        } label: {
            deleteLabel
        }
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.doubleColumn)) {
            #if os(iOS)
                        if decks.isEmpty {
                            VStack(alignment: .center) {
                                Text("tap on the plus icon\nto create a new deck")
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                .edgesIgnoringSafeArea(.all)
                        }
            #endif
           
            deckList()
                .navigationTitle("Fishky")
        } detail: {
            if let currentDeck {
                DeckView(currentDeck)
            } else {
                Text("Select or create a deck")
            }
        }

    }
    
    
    // MARK: deckList
    
    private func deckList() -> some View {
        List(selection: $currentDeck) {
            ForEach(decks) { deck in
                deckListItem(deck)
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
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
    }
    
    
    // MARK: deckListItem
    
    private func deckListItem(_ deck: Deck) -> some View {
        NavigationLink(value: deck) {
            if deck.name.isEmpty {
                Text("Untitled deck").italic().foregroundColor(.gray)
            } else {
                Text(deck.name)
            }
        }
        .contextMenu {
            deleteItemButton(deck)
        }
    }
    
    
    
    // MARK: STATE
    
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
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            Deck.deleteItems(at: offsets, for: decks)
        }
    }
}



// MARK: PREVIEW

#Preview {
    ContentView()
        .modelContainer(previewContainer)
}
#Preview("empty") {
    ContentView()
}
