import SwiftUI
import SwiftData
import os

@Observable
class FlashcardListState {
    private(set) var deck: Deck
    
    var reorderedFlashcard: Flashcard?
    var reorderInProgress: Bool { reorderedFlashcard != nil }
    
    private(set) var selectedFlashcards: Set<Int> = []

   
    init(deck: Deck) {
        self.deck = deck
    }
    

    func isSelected(flashcard: Flashcard) -> Bool {
        selectedFlashcards.contains(flashcard.order)
    }
    
    func toggleSelection(_ flashcard: Flashcard) {
        let selectedIndex = selectedFlashcards.firstIndex(of: flashcard.order) ?? nil
        let isSelected = selectedIndex != nil
        
        if isSelected {
            selectedFlashcards.remove(at: selectedIndex!)
        } else {
            selectedFlashcards.insert(flashcard.order)
        }
    }
    
    func resetSelection() {
        selectedFlashcards = []
    }
    
    func deleteFlashcards() {
        withAnimation {
            logger.info("delete flashcards")
            deck.deleteFlashcards(selectedFlashcards)
            selectedFlashcards.removeAll()
        }
    }
    func deleteFlashcard(_ flashcard: Flashcard) {
        logger.info("delete flashcard")
        deck.deleteFlashcard(flashcard)
    }
    
    func moveFlashcard(from: IndexSet, to: Int) {
        deck.moveFlashcard(from: from, to: to)
    }
}


struct FlashcardListView: View {
    // MARK: debug variables
    let showDebugInfo: Bool = false
    
    @Environment(\.modelContext) var context
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

#if os(iOS)
    @Environment(\.editMode) var editMode
    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? false
    }
#endif

    @Query var flashcards: [Flashcard]
    @State var state: FlashcardListState
    
    @Namespace private var animation
    
    var reorderingEnabled: Bool { isEditing }
    
    let columns = [GridItem(.adaptive(minimum: 250, maximum: 350))]
    

    init(_ deck: Deck) {
        state = FlashcardListState(deck: deck)
        let deckId = deck.persistentModelID
        let predicate = #Predicate<Flashcard> { flashcard in
            flashcard.deck?.persistentModelID == deckId
        }
        _flashcards = Query(filter: predicate, sort: \.order)
    }

    var body: some View {
        AdaptiveList {
            ReorderableForEach(flashcards, active: $state.reorderedFlashcard, reorderingEnabled: reorderingEnabled) { flashcard in
                HStack {
                    #if os(iOS)
                    if isEditing {
                        Button {
                            state.toggleSelection(flashcard)
                        } label: {
                            if state.isSelected(flashcard: flashcard) {
                                Image(systemName: "checkmark.circle.fill")
                            } else {
                                Image(systemName: "circle")
                            }
                            
                        }
                    }
                    #endif
                    
                    if !isEditing {
                        FlashcardEditTile(flashcard: flashcard)
                            .overlay(alignment: .topTrailing) {
                                Circle().fill(flashcard.knowledgeColor).frame(width: 7, height: 7).padding(10)
                            }
                            .matchedGeometryEffect(id: flashcard, in: animation)
                        
                    } else {
                        FlashcardPreviewTile(flashcard: flashcard)
                            .overlay(alignment: .topTrailing) {
                                Circle().fill(flashcard.knowledgeColor).frame(width: 7, height: 7).padding(10)
                            }
                            .matchedGeometryEffect(id: flashcard, in: animation)
                            .sensoryFeedback(.selection, trigger: state.selectedFlashcards)
                    }
                    
                          
                    #if os(iOS)
                    if isEditing {
                        Image(systemName: "line.3.horizontal").opacity(0.5)
                    }
                    #endif
                }.onTapGesture {
                    state.toggleSelection(flashcard)
                }
            } moveAction: { from, to in
                state.moveFlashcard(from: from, to: to)
            }
        }.toolbar {
            #if os(iOS)
            if isEditing {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(role: .destructive) {
                        state.deleteFlashcards()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }.disabled(state.selectedFlashcards.isEmpty)
                }
            }
            #endif
        }.onChange(of: isEditing, state.resetSelection)
    }
}

// MARK: PREVIEW

#Preview(traits: .sampleData) {
    @Previewable @Query var decks: [Deck]
    
    NavigationStack {
        FlashcardListView(decks.first!)
            .padding()
        #if os(iOS)
            .toolbar {
                EditButton()
            }
            .environment(\.editMode, .constant(.active))
        #endif
    }
}

fileprivate let logger = Logger(subsystem: "FlashcardListView", category: "Views/Deck")
