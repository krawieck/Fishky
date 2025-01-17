import SwiftUI

struct NewFlashcardButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .frame(maxWidth: 9999,
                       minHeight: 150,
                       maxHeight: 200)
        }
            .buttonStyle(BorderedButtonStyle())
    }
}

#Preview {
    Group {
        NavigationStack {
            ScrollView {
                NewFlashcardButton {}
                    .padding()
            }
        }
        
    }
}

