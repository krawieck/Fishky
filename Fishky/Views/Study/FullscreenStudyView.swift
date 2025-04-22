import SwiftUI
import SwiftData
import os.log

@Observable
class FullscreenStudyState {
    var deck: Deck
    var flashcards: [Flashcard] = []
    var currentIndex: Int = 0
    var flipped: [Bool] = []
    var showButtons: [Bool] = []
    var waitingForInit: Bool = true
    
    var currentFlashcard: Flashcard { flashcards[currentIndex] }
    var noFlashcards: Bool { deck.flashcards.isEmpty }
    
    init(for deck: Deck) {
        self.deck = deck
    }
    
    func initialize() {
        logger.info("real INIT")
        deck.applyKnowlegeAtrophy()
        let shuffledFlashcards = deck.shuffledFlashcards()
        let flipped = Array(repeating: false, count: shuffledFlashcards.count)
        let showButtons = Array(repeating: false, count: shuffledFlashcards.count)
        
        self.flashcards = shuffledFlashcards
        self.flipped = flipped
        self.showButtons = showButtons
        waitingForInit = false
    }
    
    func flipFlashcard(_ index: Int) {
        flipped[index].toggle()
        withAnimation(.default.delay(0.2)) {
            showButtons[index] = true
        }
    }
    
    /// returns the desired opacity for buttons for a particular flashcard
    func opacityOfButtons(for index: Int) -> Double {
        return showButtons[index] ? 1 : 0
    }
}


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
    
    @State var state: FullscreenStudyState
    
    init(deck: Deck) {
        logger.info("fake INIT")
        self.state = FullscreenStudyState(for: deck)
    }
    init(for id: Deck.ID, with context: ModelContext) {
        let deck = context.model(for: id) as! Deck
        self.init(deck: deck)
    }
    
    
    // MARK: Body
    
    var body: some View {
        if state.waitingForInit {
            EmptyView()
        }
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(state.flashcards.enumerated()), id: \.element) { index, flashcard in
                        VStack {
                            FlashcardStudyView(flashcard: flashcard, flipped: $state.flipped[index])
                                .aspectRatio(2/3, contentMode: .fit)
                                .padding()
                                .padding(.bottom, -5)
                                .onTapGesture {
                                    state.flipFlashcard(index)
                                }
                            KnowlegeButtons(flashcard)
                                .opacity(state.opacityOfButtons(for: index))
                        }
                        // TODO: fix alignment
//                        .alignmentGuide(, computeValue: { d in -20 })
//                        .alignmentGuide(HorizontalAlignment.center, computeValue: { d in
//                            -20
//                        })
                        .containerRelativeFrame([.horizontal, .vertical])
                    }
                }
                .scrollTargetLayout()
            }
            
            .scrollTargetBehavior(.paging)
            .ignoresSafeArea()
            .background(Color.blue.opacity(0.6))
        }
        .overlay {
            if state.noFlashcards && !state.waitingForInit {
                ContentUnavailableView {
                    Label("No flashcards", systemImage: "book.pages")
                } description: {
                    Text("Deck needs to contain at least one flashcard to study")
                }
            }
        }
        .task {
            state.initialize()
        }
        #if os(iOS)
        .overlay(alignment: .topTrailing) {
            // TODO: use https://github.com/Aeastr/NotchMyProblem here
            Button("Dismiss", systemImage: "xmark") { dismiss() }
                .tint(.secondary)
                .font(.system(size: 20))
                .fontWeight(.bold)
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
                .padding(.top, 5 )
                .padding(.horizontal, 15)
        }
        #endif
        
    }
    
  
    
}

// MARK: PREVIEW

#Preview(traits: .sampleData) {
    @Previewable @Query var decks: [Deck]
    
    FullscreenStudyView(deck: decks.filter { !$0.flashcards.isEmpty }.last!)
    #if os(macOS)
        .toolbar(removing: .title)
        .toolbarBackground(.hidden, for: .windowToolbar)
    #endif
}

#Preview("empty", traits: .sampleData) {
    @Previewable @Query var decks: [Deck]
    
    FullscreenStudyView(deck: decks.filter { $0.flashcards.isEmpty }.last!)
}



fileprivate let logger = Logger(subsystem: "FullscreenStudyView", category: "Views/Study")
