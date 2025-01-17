import Foundation
import SwiftUI
import SwiftData

let sampleFlashcards: [Flashcard] = [
    Flashcard(index: 0, front: "short", back: "back"),
    Flashcard(index: 1, front: "flashcard 2", back: "this is the back of this flashcard"),
    Flashcard(index: 2, front: "tan x", back: "sinx/cosx")
    
]

let sampleDeck: Deck = {
    let deck = Deck(name: "Sample Deck")
    
    for flashcard in sampleFlashcards {
        deck.addFlashcard(flashcard)
    }
    
    return deck
}()

//@MainActor
let previewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(for: Deck.self, Flashcard.self,
                                           configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        Task { @MainActor in
            
            let context = container.mainContext
            let deck = Deck(name: "Test Deck")
            
            
            context.insert(deck)
            for flashcard in sampleFlashcards {
                deck.addFlashcard(flashcard)
            }
        }
        
        return container
    } catch {
        fatalError("Failed to create sample container: \(error.localizedDescription)")
    }
}()
