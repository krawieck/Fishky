import Foundation
import SwiftUI
import SwiftData
import PhotosUI
import os

//#if os(macOS)
//extension NSImage {
///// Returns the PNG data for the `NSImage` as a Data object.
/////
///// - Returns: A data object containing the PNG data for the image, or nil
///// in the event of failure.
/////
//    public func pngData() -> Data? {
//        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
//            return nil
//        }
//        
//        let bitmapRepresentation = NSBitmapImageRep(cgImage: cgImage)
//        return bitmapRepresentation.representation(using: .png, properties: [:])
//    }
//}
//#endif
//#if os(iOS)
//extension Image {
//    public func pngData() async -> Data? {
////        guard let cgImage = self.cgImage() else {
////            return nil
////        }
//        do {
//            return try await self.exported(as: .png)
//        } catch {
//            Logger().warning("\(error.localizedDescription)")
//            return nil
//        }
//    }
//}
//#endif



protocol Ordered {
    var order: Int { get set }
}

enum KnowlegeLevel {
    case high, low, medium
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
    
    var deck: Deck?
    
    init(index: Int, front: String = "", back: String = "") {
        self.frontText = front
        self.backText = back
        
        self.order = index
    }
    
    var description: String {
        "Flashcard(index: \(order), frontText: \(frontText), backText: \(backText))"
    }
    
    
    func updateImage(onThe side: Side, with item: PhotosPickerItem) async {
        print("gonna add this image")
        if let data = try? await item.loadTransferable(type: Data.self) {
            print("data size: \(data.count) bytes")
            switch side {
                case .back:
                print("update on back")
                backImage = data
                break
            case .front:
                print("update on front")
                frontImage = data
                break
            }
        }
        print("finished adding image:)")
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
