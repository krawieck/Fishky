import Foundation
import SwiftData
import os

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
    
}

extension Deck {
    /// Add flashcard to the end
    func addFlashcard(_ f: Flashcard = Flashcard(index: 0)) {
        f.order = flashcards.count
        flashcards.append(f)
        deckUpdated()
    }
    
    func moveFlashcard(from: IndexSet, to: Int) {
        guard !from.isEmpty else {
            print("SHOULDNT HAPPEN")
            return
        }
        
        let logger = Logger()
//        logger.info("from=\(from), to=\(to)")
//        logger.info("start = min(\(from.min()!), \(to))")
        let clampedTo = min(flashcards.count - 1, to)
        let start = min(from.min()!, to)
//        logger.info("end = max(\(from.max()!), \(to))")
        let end = max(from.max()!, clampedTo)
        
        
        var sortedFlashcards = flashcards.sorted { $0.order < $1.order }
        var index = sortedFlashcards[start].order
        sortedFlashcards.move(fromOffsets: from, toOffset: to)
        
        
        
//        logger.info("len=\(sortedFlashcards.count)")
//        logger.info("start: \(start), end: \(end)")
        
        for i in start...end {
//            logger.info("i=\(i)")
            sortedFlashcards[i].order = index
            index += 1
        }
        try? modelContext?.save()
//        logger.info("")
    }
    
    func deleteFlashcard(_ flashcard: Flashcard) {
        guard flashcard.deck?.id == id else {
            print("SHIT DONE BADLY")
            return
        }
        
        let index = flashcard.order
        
        
        let sortedFlashcards = flashcards.sorted { $0.order < $1.order }
        let toBeDeleted = flashcards.filter { $0.order == index }
        flashcards.removeAll { $0.order == index }
        for f in toBeDeleted {
            modelContext?.delete(f)
        }
        
        if sortedFlashcards.isEmpty {
            return
        }
        
        for val in sortedFlashcards[index..<sortedFlashcards.count] {
            val.order -= 1
        }
        try? modelContext?.save()
    }
    
    func deleteFlashcards(_ forDeletion: Set<Int>) {
        guard !forDeletion.isEmpty else {
            print("deleteFlashcards shouldnt have beed called")
            return
        }
        
        let start = forDeletion.min()!
        var sortedFlashcards = flashcards.sorted { $0.order < $1.order }
        let toBeDeleted = flashcards.filter { forDeletion.contains($0.order) }
        sortedFlashcards.removeAll(where: { forDeletion.contains($0.order) })
        
        for f in toBeDeleted {
            modelContext?.delete(f)
        }
        if sortedFlashcards.isEmpty {
            return
        }
        
        var i = start
        for f in sortedFlashcards[start..<sortedFlashcards.count] {
            f.order = i
            i += 1
        }
        try? modelContext?.save()

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
