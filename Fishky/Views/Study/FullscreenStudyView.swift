import SwiftUI
import SwiftData


extension FullscreenStudyView {
    struct Window: View {
        @Environment(\.modelContext) var context
        
        var deckId: Deck.ID
        
        init(for id: Deck.ID) {
            deckId = id
        }
        
        var body: some View {
            FullscreenStudyView(for: deckId, with: context)
        }
    }
}

struct FullscreenStudyView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var deck: Deck
    @State var flashcards: [Flashcard]
    @State var currentIndex: Int = 0
    @State var flipped: [Bool]
    
    var currentFlashcard: Flashcard { flashcards[currentIndex] }
    
    init(deck: Deck) {
        self.deck = deck
        let shuffledFlashcards = deck.flashcards.shuffled()
        let flipped = Array(repeating: false, count: shuffledFlashcards.count)
        
        self.flashcards = shuffledFlashcards
        self.flipped = flipped
    }
    init(for id: Deck.ID, with context: ModelContext) {
        let deck = context.model(for: id) as! Deck
        self.init(deck: deck)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(flashcards.enumerated()), id: \.element) { index, flashcard in
                        ZStack {
                            Rectangle()
//                                .fill(LinearGradient(gradient: .red.gradient,
//                                                     startPoint: .top, endPoint: .bottom))
                                .fill(Color.blue.opacity(0.6))
                                .containerRelativeFrame([.horizontal, .vertical])
                            FlashcardStudyView(flashcard: flashcard, flipped: flipped[index])
                                .padding()
                        }
                        .onTapGesture {
                            flipped[index].toggle()
                        }
                    }
                }
                .scrollTargetLayout()
            }
            
            .scrollTargetBehavior(.paging)
            .ignoresSafeArea()
        }
        .overlay {
            if flashcards.isEmpty {
                ContentUnavailableView {
                    Label("No flashcards", systemImage: "book.pages")
                } description: {
                    Text("Deck needs to contain at least one flashcard to study")
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            Button("Dismiss", systemImage: "xmark") { dismiss() }
                .tint(.secondary)
                .font(.system(size: 20))
                .fontWeight(.bold)
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
                .padding(.top, 5 )
                .padding(.horizontal, 15)
        }

    }
}

// MARK: PREVIEW

#Preview(traits: .sampleData) {
    @Previewable @Query var decks: [Deck]
    
    FullscreenStudyView(deck: decks.filter { !$0.flashcards.isEmpty }.last!)
}

#Preview("empty", traits: .sampleData) {
    @Previewable @Query var decks: [Deck]
    
    FullscreenStudyView(deck: decks.filter { $0.flashcards.isEmpty }.last!)
}

