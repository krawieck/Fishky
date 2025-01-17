import SwiftUI
import SwiftData

// MARK: DeleteButton

struct DeleteButton: View {
    let action: () -> Void

    var body: some View {
        Image(systemName: "xmark.circle.fill")
    }
}

// MARK: FlashcardEditView

struct FlashcardEditView: View {
    @Bindable var flashcard: Flashcard
    @Environment(\.colorScheme) var colorScheme
    #if os(iOS)
        @Environment(\.editMode) var editMode
        private var isEditing: Bool {
            editMode?.wrappedValue.isEditing ?? false
        }
    #endif
    @State var confirmDeletion = false

    init(flashcard: Flashcard) {
        _flashcard = Bindable(flashcard)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            LazyVStack {
                TextEditorView(text: $flashcard.frontText, hintText: "front")
                DashedLine()
                TextEditorView(text: $flashcard.backText, hintText: "back")
            }
            .padding()
            .background(.background)
            .addBorder(.gray.opacity(colorScheme == .dark ? 0.5 : 0.5), cornerRadius: 15)
        }
        #if os(iOS)
        .onChange(of: isEditing) {
            if !isEditing {
                confirmDeletion = false
            }
        }
        #endif
//        .dropDestination { items, location in
//            // TODO: use .dropDestination for adding images
//        }
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
            FlashcardEditView(flashcard: flashcards.first!)
                .safeAreaPadding(.all)
            
        }.toolbar {
            #if os(iOS)
            EditButton()
            #endif
        }
    }
}

#Preview {
    FlashcardEditView(flashcard: Flashcard(index: 0, front: "", back: "")).padding()
}
