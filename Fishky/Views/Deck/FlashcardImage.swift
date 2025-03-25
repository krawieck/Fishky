import SwiftUI
import PhotosUI

struct FlashcardPickerOrImage: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Bindable var flashcard: Flashcard
    var side: Flashcard.Side
    
    @State var pickerItem: PhotosPickerItem? = nil
    
    func picker() -> some View {
        return HStack {
            Spacer()
            PhotosPicker(selection: $pickerItem, matching: .images) {
                Image(systemName: "photo.badge.plus")
            }
            Image(systemName: "camera.fill")
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
    
    var body: some View {
        switch side {
        case .front:
            if let frontImageData = flashcard.frontImage,
               let uiImage = UIImage(data: frontImageData) {
                FlashcardImage(flashcard: flashcard, side: side, uiImage: uiImage)
            } else {
                picker().onChange(of: pickerItem, handleItemChange)
                
            }
        case .back:
            if let backImageData = flashcard.backImage,
               let uiImage = UIImage(data: backImageData) {
                FlashcardImage(flashcard: flashcard, side: side, uiImage: uiImage)
            } else {
                picker().onChange(of: pickerItem, handleItemChange)
                
            }
        }
            
            
    }
}

struct FlashcardImage: View {
    @Environment(\.colorScheme) var colorScheme
    @Bindable var flashcard: Flashcard
    var side: Flashcard.Side
    
    var uiImage: UIImage
    
    var body: some View {
        // TODO: Fullscreen view with zoom and ... button at the top with delete, replace?
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)))
            .contextMenu {
                Button("Delete", role: .destructive) {
                    flashcard.removeImage(onThe: side)
                }
            }
    }
}


struct FullscreenImage: View {
    var body: some View {
        Text("Hello, World!")
    }
}


//#Preview {
//    FlashcardImage()
//}

