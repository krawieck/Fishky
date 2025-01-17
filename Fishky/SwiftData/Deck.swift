import Foundation
import SwiftData

@Model
final class Deck: Hashable, CustomStringConvertible, Identifiable {
    var name: String = ""
    var icon: String = ""
    var timeCreated: Date = Date.now
    var timeUpdated: Date = Date.now
    
    @Relationship(deleteRule: .cascade, inverse: \Flashcard.deck)
    var flashcards = [Flashcard]()
    
    init(name: String = "", icon: String = "") {
        self.name = name
        self.icon = icon
    }
    
    var description: String {
        "Deck(name: \(name), icon: \(icon), timeCreated: \(timeCreated), timeUpdated: \(timeUpdated), flashcards: \(String(describing: flashcards))"
    }
    
    func deckUpdated() {
        self.timeUpdated = .now
    }
    
    
    // MARK: OPERATIONS
    
    static func deleteItems(at offsets: IndexSet, for decks: [Deck]) {
        if let context = decks.first?.modelContext {
            offsets.map { decks[$0] }.forEach { deck in
                context.delete(deck)
            }
            
        }
    }
    
    static func deleteItem(_ deck: Deck) {
        deck.modelContext?.delete(deck)
    }
    
    /// Add flashcard to the end
    func addFlashcard(_ f: Flashcard = Flashcard(index: 0)) {
        f.index = flashcards.count
        flashcards.append(f)
        deckUpdated()
    }
}

// MARK: PREVIEW

extension Deck {
    static var preview: Deck {
        .init(name: "Deck", icon: "paintbrush")
    }
    static var previewDecks: [Deck] {
        [
            .init(name: "Analiza Matematyczna", icon: "paintbrush"),
            .init(name: "Algebra Liniowa", icon: "scale.3d"),
            .init(name: "English", icon: "globe")
        ]

    }
}
