import SwiftUI
import UIKit

// MARK: TestingView

struct TestingView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var text1: String = "top text"
    @State var text2: String = "bottom text"
    
    var body: some View {
        ScrollView {
            VStack {
//                TextEditorViewRepresentable(text: $text1)
                HStack {
                    Spacer()
                    Button { } label: { Image(systemName: "photo") }
                }
                DashedLine()
//                TextEditorViewRepresentable(text: $text2)
                HStack {
                    Spacer()
                    Button { } label: { Image(systemName: "photo") }
                }
                
            }
            .padding()
            .background(.background)
            .addBorder(.gray.opacity(colorScheme == .dark ? 0.5 : 0.5), cornerRadius: 15)
            .padding()
        }
    }
}


// MARK: TextEditorViewRepresentable

struct TextEditorViewRepresentable: UIViewRepresentable {
    @Binding var text: String
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var height: CGFloat

    
    func makeUIView(context: Context) -> UITextView {
        let textView = getUITextView()
        
        textView.delegate = context.coordinator
        textView.placeholder = "insert text here..."
        textView.isScrollEnabled = false
        textView.isEditable = true
        
        textView.leftAnchor.constraint(equalTo: textView.leftAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: textView.rightAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: textView.topAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: textView.bottomAnchor).isActive = true
        
        
        
        return textView
    }
    
    // from swiftui to uikit
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        
        
    }
    
    func getUITextView() -> UITextView {
        let textView = UITextView(frame: .zero)
        textView.insertTextPlaceholder(with: .init(width: 50, height: 50))
        return textView
    }
    
    func sizeThatFits(
            _ proposal: ProposedViewSize,
            uiView: UITextField, context: Context
        ) -> CGSize? {
            guard
                let width = proposal.width,
                let height = proposal.height
            else { return nil }
            print("w: \(width), h: \(height)")
            return CGSize(width: width, height: height)
        }

    
    // from uikit to swiftui
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String
        
        init(text: Binding<String>) {
            self._text = text
        }
        
        func textViewDidChange(_ textView: UITextView) {
            text = textView.text ?? ""
        }
    }
}

// ==============================================================================

// MARK: Placeholder
// https://stackoverflow.com/a/50671026/8925336
extension UITextView {

    private class PlaceholderLabel: UILabel { }

    private var placeholderLabel: PlaceholderLabel {
        if let label = subviews.compactMap( { $0 as? PlaceholderLabel }).first {
            return label
        } else {
            let label = PlaceholderLabel(frame: .zero)
            label.font = font
            addSubview(label)
            return label
        }
    }

    @IBInspectable
    var placeholder: String {
        get {
            return subviews.compactMap( { $0 as? PlaceholderLabel }).first?.text ?? ""
        }
        set {
            let placeholderLabel = self.placeholderLabel
            placeholderLabel.text = newValue
            placeholderLabel.numberOfLines = 0
            let width = frame.width - textContainer.lineFragmentPadding * 2
            let size = placeholderLabel.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
            placeholderLabel.frame.size.height = size.height
            placeholderLabel.frame.size.width = width
            placeholderLabel.frame.origin = CGPoint(x: textContainer.lineFragmentPadding, y: textContainerInset.top)

            textStorage.delegate = self
        }
    }

}

extension UITextView: @retroactive NSTextStorageDelegate {

    public func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        if editedMask.contains(.editedCharacters) {
            placeholderLabel.isHidden = !text.isEmpty
        }
    }

}

// ==============================================================================







// MARK: Preview

#Preview {
//    @Previewable @State var text: String = ""
//    
//    VStack {
//        TextEditorViewRepresentable(text: $text).frame(width: .infinity, height: .infinity)
//    }
    TestingView()
}
