import SwiftUI

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}
// https://stackoverflow.com/a/69002976
struct TextEditorView: View {
    
    @Binding var text: String
    var hintText: String
    @State private var textEditorHeight: CGFloat = 20
    
    var body: some View {
        ZStack(alignment: .leading) {
            Text(text)
                .font(.system(.body))
                .foregroundColor(.clear)
                .padding(14)
                .background(GeometryReader {
                    Color.clear.preference(key: ViewHeightKey.self,
                                           value: $0.frame(in: .local).size.height)
                })
            TextEditor(text: $text)
                .font(.system(.body))
                .frame(height: max(10,textEditorHeight))
                .scrollDisabled(true)
                .background(.clear)
            if text.isEmpty {
                Text(hintText)
                    .foregroundStyle(.gray)
                    .italic()
                    .padding([.leading], 5)
            }
            
        }.onPreferenceChange(ViewHeightKey.self) { textEditorHeight = $0 }
        
    }
    
}

#Preview {
    @Previewable @State var text: String = ""
    
    TextEditorView(text: $text, hintText: "test")
        .padding()
}
