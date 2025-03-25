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


    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                ZStack {
                    TextEditorView(text: $flashcard.frontText,
                                   hintText: "front", isActive: true)

                }
//                .overlay {
//                    if frontIsTargeted {
//                        dropHoverPreview
//                    }
//                }
//                .onDrop(of: [.image], isTargeted: $frontIsTargeted) { providers in
//                    return false
//                }
                FlashcardPickerOrImage(flashcard: flashcard, side: .front)
                // ------------------------------------------------------------------------------
                DashedLine()
                // ------------------------------------------------------------------------------
                TextEditorView(text: $flashcard.backText,
                               hintText: "back", isActive: true)
                FlashcardPickerOrImage(flashcard: flashcard, side: .back)
               
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
        ScrollView {
            FlashcardPreviewTile(flashcard: flashcards.first!)
                .safeAreaPadding(.all)
            
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
