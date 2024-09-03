//
//  Flashcard.swift
//  Fishky
//
//  Created by Filip Krawczyk on 20/01/2022.
//

import SwiftUI

// MARK: DeleteButton

struct DeleteButton: View {
    let action: () -> Void

    var body: some View {
        Image(systemName: "xmark.circle.fill")
    }
}

// MARK: FlashcardEditView

struct FlashcardEditView: View {
    let handleDelete: () -> Void

    @Bindable var flashcard: Flashcard
    @Environment(\.colorScheme) var colorScheme
    #if os(iOS)
        @Environment(\.editMode) var editMode
        private var isEditing: Bool {
            editMode?.wrappedValue.isEditing ?? false
        }
    #endif
    @State var confirmDeletion = false

    init(flashcard: Flashcard, handleDelete: @escaping () -> Void) {
        _flashcard = Bindable(flashcard)
        self.handleDelete = handleDelete
    }

    func internalHandleDelete() {
        if confirmDeletion {
            handleDelete()
        } else {
            confirmDeletion = true
        }
    }

    fileprivate func input(label: String, text: Binding<String>) -> some View {
        #if os(iOS)
        return Text(text.wrappedValue)
//        return TextEditor(text: text)
        #elseif os(macOS)
        return Text(text.wrappedValue)
//        return TextEditor(text: text)
        #endif
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                input(label: "Front text", text: $flashcard.frontText)
                DashedLine()
                input(label: "Back Text", text: $flashcard.backText)
            }
            .padding()
            .contextMenu {
                // TODO: add menu items
                Button("test menu") {}
            }
            .addBorder(.gray.opacity(colorScheme == .dark ? 0.5 : 0.5), cornerRadius: 15)
            

            #if os(iOS)
                if isEditing {
                    Button(action: internalHandleDelete) {
                        if !confirmDeletion {
                            Image(systemName: "trash")
                        } else {
                            Text("Delete")
                        }

                    }.buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        .foregroundColor(confirmDeletion ? .red : .gray)
                        .background(.background)
                        .cornerRadius(20)
                        .padding(10)
                }
            #endif
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

#Preview {
    NavigationStack {
        ScrollView {
            ModelPreview { content in
                FlashcardEditView(flashcard: content) { }
                    .padding()
            }
        }
    }
}

