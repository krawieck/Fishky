import SwiftUI
import SwiftData
import os

struct FlashcardListView: View {
    @Bindable var deck: Deck
    @Query var flashcards: [Flashcard]
    @Environment(\.modelContext) var context
    
#if os(iOS)
    @Environment(\.editMode) var editMode
    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? false
    }
#endif
    init(_ deck: Deck) {
        self._deck = Bindable(deck)
        let deckId = deck.persistentModelID
        let predicate = #Predicate<Flashcard> { flashcard in
            flashcard.deck?.persistentModelID == deckId
        }
        _flashcards = Query(filter: predicate, sort: \.index)
    }
    
    var body: some View {
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
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button {
                        deleteFlashcard(flashcard)
                    } label: {
                        Label("Delete", systemImage: "xmark")
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
