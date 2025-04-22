import SwiftUI
import PhotosUI
import SwiftData

// MARK: FlashcardPreviewTile

struct FlashcardPreviewTile: View {
    @Bindable var flashcard: Flashcard
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var context
    #if os(iOS)
        @Environment(\.editMode) var editMode
        private var isEditing: Bool {
            editMode?.wrappedValue.isEditing ?? false
        }
    #endif
    
    
    init(flashcard: Flashcard) {
        _flashcard = Bindable(flashcard)
    }


    private let bottomPadding = 15.0
    
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading) {
                    Text(flashcard.frontText)
                        .multilineTextAlignment(.leading)
                        .padding([.top], 3)
                        .padding(5)
                        .padding([.bottom], bottomPadding)
                if let imageData = flashcard.frontImage,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)))
                } else {
                    HStack {
                        Spacer()
                        Image(systemName: "photo.badge.plus")
                    }.opacity(0.3)
                }
                // -----------------------------
                DashedLine()
                // -----------------------------
                Text(flashcard.backText)
                    .multilineTextAlignment(.leading)
                    .padding([.top], 3)
                    .padding(5)
                    .padding([.bottom], bottomPadding)

                if let imageData = flashcard.backImage,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)))
                       
                } else {
                    HStack {
                        Spacer()
                        Image(systemName: "photo.badge.plus")
                    }.opacity(0.3)
                }
            }
            .padding()
            .background(.background)
            .addBorder(.gray.opacity(colorScheme == .dark ? 0.5 : 0.5), cornerRadius: 15)
            
        }
    }
}



// MARK: Preview

#Preview(traits: .sampleData) {
    @Previewable @Query var flashcards: [Flashcard]
    NavigationStack {
        ZStack {
            FlashcardPreviewTile(flashcard: flashcards.first!)
                .safeAreaPadding(.all)
            FlashcardEditTile(flashcard: flashcards.first!)
                .safeAreaPadding(.all).opacity(0.2)
        }.toolbar {
            #if os(iOS)
            EditButton()
            #endif
        }
    }
}

#Preview {
    FlashcardPreviewTile(flashcard: Flashcard(index: 0, front: "", back: "")).padding()
}
