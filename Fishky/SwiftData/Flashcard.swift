import Foundation
import SwiftData
import os

protocol Ordered {
    var index: Int { get set }
}

@Model
final class Flashcard: Hashable, CustomStringConvertible, Ordered {
    var index: Int
    
    var frontText: String
    var backText: String
//    @Attribute(.externalStorage) var backImage: Data?
//    @Attribute(.externalStorage) var frontImage: Data?
    
    var deck: Deck?
    
    init(index: Int, front: String = "", back: String = "") {
        self.frontText = front
        self.backText = back
        
        self.index = index
    }
    
    var description: String {
        "Flashcard(index: \(index), frontText: \(frontText), backText: \(backText))"
    }
    
    
    // MARK: OPERATIONS
    
    func deckUpdated() {
        if let deck {
            deck.deckUpdated()
            let logger = Logger()
            logger.warning("flashcard without a deck updated")
        }
    }
    
    static func deleteItem(_ flashcard: Flashcard) {
        let index = flashcard.index
        let logger = Logger()
        logger.info("deleting flashcard \(index)")
        
        guard var flashcards = flashcard.deck?.flashcards else {
            return
        }
        let sortedFlashcards = flashcards.sorted { $0.index < $1.index }
        let toBeDeleted = flashcards.filter { $0.index == index }
        flashcards.removeAll { $0.index == index }
        for f in toBeDeleted {
            flashcard.modelContext?.delete(f)
        }
        
        logger.info("\(sortedFlashcards.count)")

        logger.info("count: \(sortedFlashcards.count)")
        print(index)
        print(sortedFlashcards.count)
//        if index == sorted.count {
//            return
//        }
        for val in sortedFlashcards[index..<sortedFlashcards.count] {
            logger.info("i: \(val.index)")
            val.index -= 1
        }
        print(sortedFlashcards)
    }
}

// MARK: PREVIEW

extension Flashcard {
    static var previewFlashcards: [Flashcard] {
        [
            .init(index: 0, front: "short", back: "back"),
            .init(index: 1, front: "flashcard 2", back: "this is the back of this flashcard"),
            .init(index: 2, front: "tan x", back: "sinx/cosx")
        ]
    }
}
