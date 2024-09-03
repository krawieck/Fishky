//
//  Flashcard.swift
//  Fishky
//
//  Created by Filip Krawczyk on 18/06/2023.
//

import Foundation
import SwiftData
import os

@Model
final class Flashcard: Hashable, CustomStringConvertible {
    var frontText: String
    var backText: String
//    var backImage: Data?
//    var frontImage: Data?
    
    var deck: Deck?
    
    init(front: String = "", back: String = "") {
        self.frontText = front
        self.backText = back
    }
    
    var description: String {
        "Flashcard(frontText: \(frontText), backText: \(backText))"
    }
    
    func deckUpdated() {
        if let deck {
            deck.deckUpdated()
            let logger = Logger()
            logger.warning("flashcard without a deck updated")
        }
    }
    
    static func deleteItem(_ flashcard: Flashcard) {
        flashcard.modelContext?.delete(flashcard)
    }
}
