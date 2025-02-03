import SwiftUI
import SwiftData
import os

struct FlashcardListView: View {
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

    
    let columns = [GridItem(.adaptive(minimum: 250, maximum: 350))]
    func flashcardDeleteButton(_ flashcard: Flashcard) -> some View {
        Button {
            deleteFlashcard(flashcard)
        } label: {
            Image(systemName: "xmark")
                .padding(8)
        }.tint(.gray.opacity(0.8))
    }
    
    init(_ deck: Deck) {
        self._deck = Bindable(deck)
        let deckId = deck.persistentModelID
        let predicate = #Predicate<Flashcard> { flashcard in
            flashcard.deck?.persistentModelID == deckId
        }
        _flashcards = Query(filter: predicate, sort: \.index)
    }
    
    
    
    var body: some View {
        if horizontalSizeClass == .compact {
            
            ForEach(flashcards) { flashcard in
                FlashcardEditView(flashcard: flashcard)
                    .id(flashcard.id)
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button {
                            deleteFlashcard(flashcard)
                        } label: {
                            Label("Delete", systemImage: "xmark")
                        }
                    }
                    .contextMenu {
                        Button {
                            deleteFlashcard(flashcard)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                #if os(iOS)
                    .overlay(alignment: .topTrailing) {
                        if isEditing {
                            flashcardDeleteButton(flashcard)
                        }
                    }
                #endif
            }
        } else {
            LazyVGrid(columns: columns) {
                ForEach(flashcards) { flashcard in
                    FlashcardEditView(flashcard: flashcard)
                        .overlay(alignment: .topTrailing) {
#if os(iOS)
                            if editMode?.wrappedValue.isEditing ?? false {
                                Button(action: { deleteFlashcard(flashcard) }) {
                                    Image(systemName: "trash").foregroundStyle(.red)
                                }
                                .buttonStyle(.bordered)
                                .buttonBorderShape(.capsule)
                                .foregroundColor(.gray)
                                .background(.background)
                                .cornerRadius(20)
                                .padding(10)
                            }
#endif
                        }
                        .id(flashcard.id)
                        .listRowSeparator(.hidden)
                    #if os(iOS)
                        .overlay(alignment: .topTrailing) {
                            if isEditing {
                                flashcardDeleteButton(flashcard)
                            }
                        }
                    #endif
                }
            }
        }
        
    }
}

// MARK: STATE

extension FlashcardListView {
    func deleteFlashcard(_ flashcard: Flashcard) {
        withAnimation(.spring) {
            let logger = Logger()
            logger.info("delete flashcard")
            Flashcard.deleteItem(flashcard)
            try? context.save()
        }
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
