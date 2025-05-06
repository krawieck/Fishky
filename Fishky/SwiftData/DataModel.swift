import SwiftUI
import SwiftData

actor DataModel {
    struct TransactionAuthor {
        static let widget = "widget"
    }
    
    static let shared = DataModel()
    private init() {}
    
    // if problem in development:
    // How to clear locally cached SwiftData database on macOS
    // https://developer.apple.com/forums/thread/748964?answerId=783595022#783595022
    nonisolated lazy var modelContainer: ModelContainer = {
        let modelContainer: ModelContainer
        do {
            modelContainer = try ModelContainer(for: Deck.self, Flashcard.self)
        } catch {
            fatalError("Failed to create the model container: \(error)")
        }
        
        return modelContainer
    }()
}
