//
//  DeckView.swift
//  Fishky
//
//  Created by Filip Krawczyk on 03/07/2023.
//

import SwiftUI
import os

struct StudyButton: View {
    let action: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: action) {
                    Label("Study", systemImage: "graduationcap.fill")
                }.buttonStyle(BorderedProminentButtonStyle())
                    .padding()
            }
        }
    }
}

struct DeckView: View {
    @Environment(\.modelContext) private var context
    @Bindable var deck: Deck
    @State var studyMode: Bool = false
    
    init(_ deck: Deck) {
        self._deck = Bindable(deck)
    }
    
    var body: some View {
        ZStack {
            List {
                TextField("Untitled Deck", text: $deck.name).font(.largeTitle.bold())//.padding()
                    .listRowSeparator(.hidden)
                ForEach(deck.flashcards) { flashcard in
                    FlashcardEditView(flashcard: flashcard) {
                        deleteFlashcard(flashcard)
                    }.id(flashcard.id)
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing) {
                            Button {} label: {
                                Label("Delete", systemImage: "xmark")
                            }
                        }
                }
                NewFlashcardButton {
                    addFlashcard()
                }.listRowSeparator(.hidden)
                Spacer() // for study button
                    .frame(height: 50)
                    .listRowSeparator(.hidden)
            }
            
            StudyButton {
                studyMode.toggle()
            }
        }.listStyle(.plain).listRowSeparator(.hidden)
        .navigationDestination(isPresented: $studyMode) {
            EmptyView()
            //            StudyView(deck: deck)
        }
#if os(iOS)
        .scrollDismissesKeyboard(.interactively)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(deck.name).font(.headline).truncationMode(.middle)
            }
#if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
#endif
        }
        .onDisappear {
            let logger = Logger()
            logger.info("onDisappear")
            print("TEST")
            print(deck.description)
            withAnimation {
                if deck.name.isEmpty && deck.flashcards.isEmpty && deck.icon.isEmpty {
                    logger.info("DELETE DECK")
                    deleteDeck()
                }
                try? context.save()
            }
        }
    }
    
    
    // MARK: STATE
    
    func addFlashcard() {
        withAnimation(.interactiveSpring()) {
            deck.addFlashcard()
        }
        try? context.save()
    }
    
    func deleteDeck() {
        withAnimation {
            Deck.deleteItem(deck)
        }
    }
    
    func deleteFlashcard(_ flashcard: Flashcard) {
        withAnimation {
            let logger = Logger()
            logger.info("delete flashcard")
            Flashcard.deleteItem(flashcard)
            try? context.save()
        }
    }
}


#Preview {
    ModelPreview() { content in
        NavigationStack {
            DeckView(content)
        }
        
    }
}

#Preview("StudyButton") {
    StudyButton {}
}
