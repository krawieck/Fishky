import SwiftUI
import PhotosUI
import SwiftData

// MARK: DeleteButton

struct DeleteButton: View {
    let action: () -> Void

    var body: some View {
        Image(systemName: "xmark.circle.fill")
    }
}

// MARK: FlashcardEditView

struct FlashcardEditTile: View {
    @Bindable var flashcard: Flashcard
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var context
    #if os(iOS)
        @Environment(\.editMode) var editMode
        private var isEditing: Bool {
            editMode?.wrappedValue.isEditing ?? false
        }
    #endif
    
    @State var frontIsTargeted: Bool = false
    @State var backIsTargeted: Bool = false
    
    init(flashcard: Flashcard) {
        _flashcard = Bindable(flashcard)
//        self.selection = []
    }

    var dropHoverPreview: some View {
        ZStack {
            HStack {
                Image(systemName: "photo.badge.plus")
                Text("Drop image here")
                
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                TextEditorView(text: $flashcard.frontText,
                               hintText: "front")
                .overlay {
                    if frontIsTargeted {
                        dropHoverPreview
                    }
                }
             
                FlashcardPickerOrImage(flashcard: flashcard, side: .front)
                // ----------------------------------------------------------
                DashedLine()
                // ----------------------------------------------------------
                TextEditorView(text: $flashcard.backText,
                               hintText: "back")
                .onDrop(of: [.image], isTargeted: $backIsTargeted) { providers in
                    return false
                }
                .overlay {
                    if backIsTargeted {
                        dropHoverPreview
                    }
                }
                FlashcardPickerOrImage(flashcard: flashcard, side: .back)
            }
            .padding()
            .background(.background)
            .addBorder(.gray.opacity(colorScheme == .dark ? 0.5 : 0.5), cornerRadius: 15)
            
            
            
        }
    }
    
    func deleteFlashcard(_ flashcard: Flashcard) {
       withAnimation {
           flashcard.deck?.deleteFlashcard(flashcard)
           try? context.save()
       }
       
   }
}

// MARK: Border

public extension View {
    func addBorder<S>(_ content: S, width: CGFloat = 1, cornerRadius: CGFloat) -> some View where S: ShapeStyle {
        let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
        return clipShape(roundedRect)
            .overlay(roundedRect.strokeBorder(content, lineWidth: width))
    }
}

// MARK: Dashed line

struct DashedLine: View {
    var body: some View {
        Line()
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
            .foregroundColor(Color.gray.opacity(0.6))
            .frame(height: 1)
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

// MARK: Preview

#Preview(traits: .sampleData) {
    @Previewable @Query var flashcards: [Flashcard]
    NavigationStack {
        ScrollView {
            FlashcardEditTile(flashcard: flashcards.first!)
                .safeAreaPadding(.all)
            
        }.toolbar {
            #if os(iOS)
            EditButton()
            #endif
        }
    }
}

#Preview {
    FlashcardEditTile(flashcard: Flashcard(index: 0, front: "", back: "")).padding()
}
