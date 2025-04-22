import SwiftUI
import SwiftData
import os.log

struct KnowledgeButtons: View {
    @Bindable var flashcard: Flashcard
    @State var newKnowledge: KnowledgeLevel? = nil
    
    var body: some View {
        return HStack {
            Button {
                updateKnowledge(.high, for: flashcard)
            } label: {
                Image(systemName: "hand.thumbsup.fill")
                    .font(.system(.title2))
                    .padding(.all, 5)
            }.buttonStyle(.borderedProminent)
                .buttonBorderShape(.circle)
                .tint(newKnowledge != nil && newKnowledge != .high ? .gray : .green)
            Button {
                updateKnowledge(.medium, for: flashcard)
            } label: {
                Text("🤔")
                    .font(.system(.title))
            }.buttonStyle(.borderedProminent)
                .buttonBorderShape(.circle)
                .tint(newKnowledge != nil && newKnowledge != .medium ? .gray : .indigo)
            Button {
                updateKnowledge(.low, for: flashcard)
            } label: {
                Image(systemName: "hand.thumbsdown.fill")
                    .font(.system(.title2))
                    .padding(.all, 5)
            }.buttonStyle(.borderedProminent)
                .buttonBorderShape(.circle)
                .tint(newKnowledge != nil && newKnowledge != .low ? .gray : .red)
        }.sensoryFeedback(.impact, trigger: newKnowledge)
    }
    
    func updateKnowledge(_ knowledgeLevel: KnowledgeLevel, for flashcard: Flashcard) {
        newKnowledge = knowledgeLevel
        logger.info("newKnowledge = \(newKnowledge.debugDescription)")
        flashcard.updateKnowledge(knowledgeLevel)
        logger.info("\(flashcard)")
    }
}



extension KnowledgeButtons {
    init(_ flashcard: Flashcard) {
        self.init(flashcard: flashcard)
    }
}


#Preview(traits: .sampleData) {
    @Previewable @Query var decks: [Deck]
    
    
    if let flashcard = decks.first(where: { !$0.flashcards.isEmpty })?.flashcards.first {
        NavigationStack {
            KnowledgeButtons(flashcard)
        }
    } else {
        Text(":(")
    }
    
    
}

fileprivate let logger = Logger(subsystem: "KnowledgeButtons", category: "Views/Study")
