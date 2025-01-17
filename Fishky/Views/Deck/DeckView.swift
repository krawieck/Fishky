import SwiftData
import SwiftUI
import os

struct StudyButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label("Study", systemImage: "graduationcap.fill")
        }.buttonStyle(BorderedProminentButtonStyle())
            .padding()
    }
}

extension DeckView {
    struct Window: View {
        @Environment(\.modelContext) var context
        
        var deckId: Deck.ID
        
        init(for id: Deck.ID) {
            deckId = id
        }
        
        var body: some View {
            DeckView(for: deckId, with: context)
        }
    }
}

struct DeckView: View {
    @Environment(\.openWindow) var openWindow
    @Environment(\.modelContext) private var context
    @Bindable var deck: Deck
    @State var studyMode: Bool = false
    
    // MARK: INIT
    
    init(_ deck: Deck) {
        self._deck = Bindable(deck)
    }
    init(for id: Deck.ID, with context: ModelContext) {
        let deck = context.model(for: id) as! Deck
        self.init(deck)
    }
    
    // MARK: BODY
    
    var body: some View {
        List {
            TextField("Untitled Deck", text: $deck.name)
                .font(.largeTitle.bold())
                .listRowSeparator(.hidden)
            FlashcardListView(deck)
                .navigationTitle($deck.name)
            
            NewFlashcardButton {
                withAnimation(.bouncy) {
                    addFlashcard()
                }
            }.listRowSeparator(.hidden)
            Spacer() // for study button
                .frame(height: 50)
                .listRowSeparator(.hidden)
            
        }
        .navigationTitle($deck.name)
        .listStyle(.plain)
        .listRowSeparator(.hidden)
        .toolbar {
#if os(macOS)
            ToolbarItem(placement: .primaryAction) {
                Button {
                    openWindow(id: "study", value: deck.id)
                } label: {
                    Label("Study", systemImage: "graduationcap.fill")
                }
                .buttonStyle(.borderedProminent)
                
            }
#endif
#if os(iOS)
           
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
#endif
        }
        
#if os(iOS)
        .overlay(alignment: .bottomTrailing) {
            StudyButton {
                studyMode.toggle()
            }
        }
#endif
#if os(iOS)
        .scrollDismissesKeyboard(.interactively)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $studyMode) {
            FullscreenStudyView(deck: deck)
        }
#endif
        .onDisappear {
            let logger = Logger()
            withAnimation {
                if deck.name.isEmpty && deck.flashcards.isEmpty && deck.icon.isEmpty {
                    logger.info("DELETE DECK")
                    deleteDeck()
                }
                do {
                    context.insert(deck)
                    try context.save()
                } catch {
                    logger.error("\(error)")
                }
            }
        }
    }
}

// MARK: STATE

extension DeckView {
    func addFlashcard() {
        deck.addFlashcard()
        try? context.save()
    }
    
    func deleteDeck() {
        withAnimation {
            Deck.deleteItem(deck)
        }
    }
}

// MARK: PREVIEW

#Preview(traits: .sampleData) {
    @Previewable @Query var decks: [Deck]
    
    NavigationStack {
        DeckView(decks.last!)
    }
    //.environment(\.editMode, .constant(.active))
}

#Preview("StudyButton") {
    StudyButton {}
}
