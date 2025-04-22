import Foundation
import SwiftUI
import SwiftData
import PhotosUI
import os

protocol Ordered {
    var order: Int { get set }
}

enum KnowledgeLevel: Int, Codable, CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
            case .low:
                return ".low"
            case .medium: 
                return ".medium"
            case .high: 
                return ".high"
        }
    }
    
    case low = 0
    case medium = 1
    case high = 2
}

struct KnowledgeData: Codable, CustomDebugStringConvertible {
    var debugDescription: String {
        "KnowledgeData(\(expires), \(level))"
    }
    
    let expires: Date
    let level: KnowledgeLevel
}

@Model
final class Flashcard: Hashable, CustomStringConvertible, Ordered, Reorderable {
    enum Side {
        case front, back
    }
    
    @Attribute(originalName: "index")
    var order: Int
    
    var frontText: String
    var backText: String
    @Attribute(.externalStorage) var backImage: Data?
    @Attribute(.externalStorage) var frontImage: Data?
    
    var knowledgeData: KnowledgeData?
    
    var deck: Deck?
    
    init(index: Int, front: String = "", back: String = "", knowledgeData: KnowledgeData? = nil) {
        self.frontText = front
        self.backText = back
        
        self.order = index
        self.knowledgeData = knowledgeData
    }
    
    var description: String {
        "Flashcard(index: \(order), frontText: \(frontText), backText: \(backText))"
    }
    
    var knowledgeColor: Color {
        switch knowledgeData?.level {
        case .low:
            .red
        case .medium:
            .yellow
        case .high:
            .green
        case nil:
            .clear
        }
    }
    
    
    func updateImage(onThe side: Side, with item: PhotosPickerItem) async {
        logger.info("gonna add this image")
        if let data = try? await item.loadTransferable(type: Data.self) {
            logger.info("data size: \(data.count) bytes")
            switch side {
                case .back:
                logger.info("update on back")
                backImage = data
                break
            case .front:
                logger.info("update on front")
                frontImage = data
                break
            }
        }
        logger.info("finished adding image:)")
    }

    func removeImage(onThe side: Side) {
        switch side {
            case .back:
            backImage = nil
            break
        case .front:
            frontImage = nil
            break
        }
    }
    
    func updateKnowledge(_ knowledgeLevel: KnowledgeLevel, expires: Date? = nil) {
        knowledgeData = KnowledgeData(expires: expires ?? Date(timeInterval: knowledgeExpiryTime, since: Date.now), level: knowledgeLevel)
        
        logger.info("knowledge updated for flashcard \(self.order) \(self.knowledgeData?.level.rawValue ?? -1)")
    }
    
    // MARK: OPERATIONS
    func deckUpdated() {
        if let deck {
            deck.deckUpdated()
        } else {
            let logger = Logger()
            logger.warning("flashcard without a deck updated")
        }
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

fileprivate let logger = Logger(subsystem: "Flashcard", category: "SwiftData")
