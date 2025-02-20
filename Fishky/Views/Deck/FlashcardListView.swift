import SwiftUI
import SwiftData
import os


struct FlashcardFocus {
    let flashcard: Flashcard
    let side: FlashcardSide
    
    enum FlashcardSide {
        case front, back
    }
}


struct FlashcardListView: View {
    // MARK: debug variables
    let debugShowIndex: Bool = true
    
    //
    
    @Environment(\.modelContext) var context
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

#if os(iOS)
    @Environment(\.editMode) var editMode
    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? false
    }
#endif

    @Bindable var deck: Deck
    @Query var flashcards: [Flashcard]
    @State var flashcardFocus: FlashcardFocus?
    
    @State var reorderedFlashcard: Flashcard?
    var reorderInProgress: Bool { reorderedFlashcard != nil }
    
    @State var selectedFlashcards: Set<Int> = []

    
    let columns = [GridItem(.adaptive(minimum: 250, maximum: 350))]
    func flashcardDeleteButton(_ flashcard: Flashcard) -> some View {
        Button {
            deleteFlashcard(flashcard)
        } label: {
            Image(systemName: "xmark")
                .padding(8)
        }.tint(.gray.opacity(0.8))
    }
    
//    func keyboardToolbar() -> some View {
//        return ToolbarItemGroup(placement: .keyboard) {
//            Button {
//                if let flashcardFocus {
//                    if flashcardFocus.side == .front {
//                        print("\(flashcardFocus.flashcard.frontText)")
//                    } else {
//                        print("\(flashcardFocus.flashcard.frontText)")
//                    }
//                }
//            } label: {
//                Label("Add image", systemImage: "photo.badge.plus.fill")
//            }
//        }
//    }
    
    
    init(_ deck: Deck) {
        self._deck = Bindable(deck)
        let deckId = deck.persistentModelID
        let predicate = #Predicate<Flashcard> { flashcard in
            flashcard.deck?.persistentModelID == deckId
        }
        _flashcards = Query(filter: predicate, sort: \.order)
    }
    
    
    
    var body: some View {
        AdaptiveList {
            ReorderableForEach(flashcards, active: $reorderedFlashcard) { flashcard in
                HStack {
                    #if os(iOS)
                    if isEditing {
                        Button {
                            toggleSelection(flashcard)
                        } label: {
                            let isSelected = selectedFlashcards.contains(flashcard.order)
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                            } else {
                                Image(systemName: "circle")
                            }
                            
                        }
                    }
                    #endif
                    
                    #if os(iOS)
                    FlashcardEditTile(flashcard: flashcard, inactive: isEditing)
                        .onTapGesture {
                            print("GESTURE RECOGNIZEd")
                            
                            if isEditing {
                                toggleSelection(flashcard)
                            }
                        }
                        .overlay {
                            if debugShowIndex {
                                Text("\(flashcard.order)")
                            }
                        }
                    #else
                    FlashcardEditTile(flashcard: flashcard)
                        .overlay {
                            if debugShowIndex {
                                Text("\(flashcard.order)")
                            }
                        }
                    #endif
//                        .id(flashcard.id)
//                        .listRowSeparator(.hidden)
                        
                    #if os(iOS)
                    if isEditing {
                        Image(systemName: "line.3.horizontal").opacity(0.5)
                    }
                    #endif
                    
                    
                }
            } moveAction: { from, to in
                deck.moveFlashcard(from: from, to: to)
            }
            
        }.toolbar {
            #if os(iOS)
            if isEditing {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(role: .destructive) {
                        deleteFlashcards()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }.disabled(selectedFlashcards.isEmpty)
                }
            }
            #endif
        }
    }
}

// MARK: STATE

extension FlashcardListView {
    func toggleSelection(_ flashcard: Flashcard) {
        let selectedIndex = selectedFlashcards.firstIndex(of: flashcard.order) ?? nil
        let isSelected = selectedIndex != nil
        
        if isSelected {
            selectedFlashcards.remove(at: selectedIndex!)
        } else {
            selectedFlashcards.insert(flashcard.order)
        }
    }
    
    func deleteFlashcards() {
        withAnimation(.spring) {
            let logger = Logger()
            logger.info("delete flashcards")
            deck.deleteFlashcards(selectedFlashcards)
            selectedFlashcards.removeAll()
            try? context.save()
        }
    }
    func deleteFlashcard(_ flashcard: Flashcard) {
        withAnimation(.spring) {
            let logger = Logger()
            logger.info("delete flashcard")
            deck.deleteFlashcard(flashcard)
            try? context.save()
        }
    }
    
    func flashcardUpdateFocus(flashcard: Flashcard, onThe side: FlashcardFocus.FlashcardSide) {
        flashcardFocus = FlashcardFocus(flashcard: flashcard, side: side)
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
