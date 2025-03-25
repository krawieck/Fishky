import SwiftUI
import SwiftData

// inspo: https://github.com/jrasmusson/swiftui/blob/main/Animations/CardFlip/README.md

struct Card: View {
    let text: String
    let imageData: Data?
    
    @Binding var degree: Double
    
    var body: some View {
        RoundedRectangle(cornerRadius: 30)
            .fill(Color.white)
            .shadow(color: .black.opacity(0.2), radius: 5)
            .aspectRatio(2/3, contentMode: .fit)
            .overlay {
                VStack {
                    Text(text)
                        .colorScheme(.light)
                    if let frontImageData = imageData,
                       let uiImage = UIImage(data: frontImageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)))
                            
                    }
                }.padding()
            }
            .rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 10, z: 0))
    }
}

extension Card {
    init(_ text: String, imageData: Data?, degree: Binding<Double>) {
        self.init(text: text, imageData: imageData, degree: degree)
    }
}

enum FlipSpeed: TimeInterval {
    case instant = 0.0, fast = 0.1, regular = 0.15, slow = 0.2
}

struct FlashcardStudyView: View {
    @Bindable var flashcard: Flashcard
    @Binding var flipped: Bool
    
    @State var backDegree = 90.0
    @State var frontDegree = 0.0
    
    let duration: TimeInterval = FlipSpeed.regular.rawValue

    var body: some View {
        ZStack {
            Card(flashcard.frontText, imageData: flashcard.frontImage, degree: $frontDegree)
            Card(flashcard.backText, imageData: flashcard.backImage, degree: $backDegree)
        }.onChange(of: flipped, flipHandler)
    }

    // MARK: STATE
    
    func flipHandler(_ oldFlipped: Bool, _ newFlipped: Bool) {
        if !newFlipped {
            withAnimation(.easeIn(duration: duration)) {
                backDegree = 90
            }
            withAnimation(.easeOut(duration: duration).delay(duration)) {
                frontDegree = 0
            }
        } else {
            withAnimation(.easeIn(duration: duration)) {
                frontDegree = -90
            }
            withAnimation(.easeOut(duration: duration).delay(duration)) {
                backDegree = 0
            }
        }
    }
}


// MARK: PREVIEW

#Preview(traits: .sampleData) {
    @Previewable @Query var flashcards: [Flashcard]
    @Previewable @State var flipped: Bool = false
    
    FlashcardStudyView(flashcard: flashcards.first!, flipped: $flipped)
        .padding()
        .background(Color.blue.opacity(0.6))
        .onTapGesture {
            flipped.toggle()
        }
    
}
