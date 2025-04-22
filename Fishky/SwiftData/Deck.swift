import Foundation
import SwiftData
import os

private let secondsInDay: TimeInterval = 60 * 60 * 24
let knowledgeExpiryTime: TimeInterval = secondsInDay * 7

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
    
    var percentageComplete: Double {
        flashcards
            .map {
                switch $0.knowledgeData?.level {
                case .low:
                    0.1
                case .medium:
                    0.6
                case .high:
                    1.0
                case nil:
                    0.0
                }
            }.reduce(0, +) / Double(flashcards.count)
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
            logger.error("SHOULDNT HAPPEN")
            return
        }
        
        let clampedTo = min(flashcards.count - 1, to)
        let start = min(from.min()!, to)
        let end = max(from.max()!, clampedTo)
        
        
        var sortedFlashcards = flashcards.sorted { $0.order < $1.order }
        var index = sortedFlashcards[start].order
        sortedFlashcards.move(fromOffsets: from, toOffset: to)
        
        for i in start...end {
            sortedFlashcards[i].order = index
            index += 1
        }
        try? modelContext?.save()
    }
    
    func deleteFlashcard(_ flashcard: Flashcard) {
        guard flashcard.deck?.id == id else {
            logger.error("SHIT DONE BADLY")
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
            logger.error("deleteFlashcards shouldnt have beed called")
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
    
    /// update knowledge based on Date. downgrade the ones that are expired
    func applyKnowledgeAtrophy() {
        for flashcard in flashcards {
            if let knowledgeData = flashcard.knowledgeData {
                // if expired then either bump the level of knowledge down, or remove it
                if knowledgeData.expires > Date.now {
                    switch knowledgeData.level {
                    case .low:
                        flashcard.knowledgeData = nil
                    case .medium:
                        flashcard.knowledgeData = KnowledgeData(expires: Date(timeInterval: knowledgeExpiryTime, since: Date.now), level: .low)
                    case .high:
                        flashcard.knowledgeData = KnowledgeData(expires: Date(timeInterval: knowledgeExpiryTime, since: Date.now), level: .medium)
                    }
                }
            }
        }
    }
    
    func shuffledFlashcards() -> [Flashcard] {
        logger.info("shuffling")
        let unranked = flashcards.filter { $0.knowledgeData == nil }.shuffled()
        let lowKnowledge = flashcards.filter { $0.knowledgeData?.level == .low }.shuffled()
        let mediumKnowledge = flashcards.filter { $0.knowledgeData?.level == .medium }.shuffled()
        let highKnowledge = flashcards.filter { $0.knowledgeData?.level == .high }.shuffled()
        
        logger.info("""
                    unranked: \(unranked)
                    low: \(lowKnowledge)
                    medium: \(mediumKnowledge)
                    high: \(highKnowledge)
                    """)
        
        logger.info("""
                    LEN
                    unranked: \(unranked.count)
                    low: \(lowKnowledge.count)
                    medium: \(mediumKnowledge.count)
                    high: \(highKnowledge.count)
                    """)
        
        
        

        return unranked + lowKnowledge + mediumKnowledge + highKnowledge
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

fileprivate let logger = Logger(subsystem: "Deck", category: "SwiftData")
