import SwiftUI
import PhotosUI

// MARK: State

@MainActor
@Observable
class PickerState {
    private(set) var flashcard: Flashcard
    let side: Flashcard.Side
    var pickerItem: PhotosPickerItem? = nil
    
    init(flashcard: Flashcard, side: Flashcard.Side) {
        self.flashcard = flashcard
        self.side = side
    }
    
    var imageData: Data? {
        switch side {
        case .front:
            flashcard.frontImage
        case .back:
            flashcard.backImage
        }
    }
    
    var uiImage: UIImage? {
        if let imageData {
            UIImage(data: imageData)
        } else {
            nil
        }
    }
    
    func handleItemChange(oldValue: PhotosPickerItem?, newValue: PhotosPickerItem?) {
        if let newValue {
            Task {
                await flashcard.updateImage(onThe: side, with: newValue)
                pickerItem = nil
            }
        }
    }
    
    func handleRemoveImage() {
        flashcard.removeImage(onThe: side)
    }
}

// MARK: View

struct FlashcardPickerOrImage: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var state: PickerState
    
    init(flashcard: Flashcard, side: Flashcard.Side) {
        self.state = PickerState(flashcard: flashcard, side: side)
    }
    
    
    var body: some View {
        if let uiImage = state.uiImage {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)))
                .contextMenu {
                    Button("Delete", role: .destructive, action: state.handleRemoveImage)
                }
        } else {
            picker().onChange(of: state.pickerItem, state.handleItemChange)
        }
    }
    
    func picker() -> some View {
        return HStack {
            Spacer()
            PhotosPicker(selection: $state.pickerItem, matching: .images) {
                Image(systemName: "photo.badge.plus")
            }
        }
    }
}


//#Preview {
//    FlashcardImage()
//}

