import SwiftUI
import SwiftData
import os.log

struct KnowlegeButtons: View {
    @Bindable var flashcard: Flashcard
    @State var newKnowlege: KnowlegeLevel? = nil
    
    var body: some View {
        return HStack {
            Button {
                updateKnowlege(.high, for: flashcard)
            } label: {
                Image(systemName: "hand.thumbsup.fill")
                    .font(.system(.title2))
                    .padding(.all, 5)
            }.buttonStyle(.borderedProminent)
                .buttonBorderShape(.circle)
                .tint(newKnowlege != nil && newKnowlege != .high ? .gray : .green)
            Button {
                updateKnowlege(.medium, for: flashcard)
            } label: {
                Text("🤔")
                    .font(.system(.title))
            }.buttonStyle(.borderedProminent)
                .buttonBorderShape(.circle)
                .tint(newKnowlege != nil && newKnowlege != .medium ? .gray : .indigo)
            Button {
                updateKnowlege(.low, for: flashcard)
            } label: {
                Image(systemName: "hand.thumbsdown.fill")
                    .font(.system(.title2))
                    .padding(.all, 5)
            }.buttonStyle(.borderedProminent)
                .buttonBorderShape(.circle)
                .tint(newKnowlege != nil && newKnowlege != .low ? .gray : .red)
        }
    }
    
    func updateKnowlege(_ knowlegeLevel: KnowlegeLevel, for flashcard: Flashcard) {
        newKnowlege = knowlegeLevel
        logger.info("newKnowlege = \(newKnowlege.debugDescription)")
        flashcard.updateKnowlege(knowlegeLevel)
        logger.info("\(flashcard)")
    }
}



extension KnowlegeButtons {
    init(_ flashcard: Flashcard) {
        self.init(flashcard: flashcard)
    }
}


#Preview(traits: .sampleData) {
    @Previewable @Query var decks: [Deck]
    
    
    if let flashcard = decks.first(where: { !$0.flashcards.isEmpty })?.flashcards.first {
        NavigationStack {
            KnowlegeButtons(flashcard)
        }
    } else {
        Text(":(")
    }
    
    
}

fileprivate let logger = Logger(subsystem: "KnowlegeButtons", category: "Views/Study")
