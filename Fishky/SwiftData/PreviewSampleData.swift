import SwiftData
import SwiftUI

/**
 Preview sample data.
 */
struct SampleData: PreviewModifier {
    static func makeSharedContext() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Deck.self, Flashcard.self,
            configurations: config
        )
        SampleData.createSampleData(into: container.mainContext)
        return container
    }
    
    func body(content: Content, context: ModelContainer) -> some View {
          content.modelContainer(context)
    }
    
    static func createSampleData(into modelContext: ModelContext) {
        Task { @MainActor in
            let sampleDecks: [Deck] = Deck.previewDecks
            let sampleFlashcards: [Flashcard] = Flashcard.previewFlashcards
            let sampleData: [any PersistentModel] = sampleDecks + sampleFlashcards
            sampleData.forEach {
                modelContext.insert($0)
            }
            
            if let firstDeck = sampleDecks.first,
               let firstFlashcard = sampleFlashcards.first {
                firstDeck.flashcards.append(firstFlashcard)
            }
            if let lastDeck = sampleDecks.last,
               let lastFlashcard = sampleFlashcards.last {
                lastDeck.flashcards.append(lastFlashcard)
            }
            try? modelContext.save()
        }
    }
}

@available(iOS 18.0, *)
extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var sampleData: Self = .modifier(SampleData())
}
