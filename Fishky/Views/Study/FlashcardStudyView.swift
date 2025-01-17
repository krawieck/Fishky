import SwiftUI
import SwiftData

struct FlashcardStudyView: View {
    @Bindable var flashcard: Flashcard
    var flipped: Bool
    
    var body: some View {
        if !flipped {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.2), radius: 5)
                .aspectRatio(2/3, contentMode: .fit)
                .overlay {
                    Text(flashcard.frontText)
                }
        } else {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.2), radius: 5)
                .aspectRatio(2/3, contentMode: .fit)
                .overlay {
                    Text(flashcard.backText)
                }
        }
    }
}

// MARK: PREVIEW

#Preview(traits: .sampleData) {
    @Previewable @Query var flashcards: [Flashcard]
    
    
    FlashcardStudyView(flashcard: flashcards.first!, flipped: false)
        .padding()
        .background(Color.blue.opacity(0.6))
    
}
