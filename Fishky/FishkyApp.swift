import SwiftUI
import SwiftData

@main
struct FishkyApp: App {
    let modelContainer = DataModel.shared.modelContainer

    var body: some Scene {
        WindowGroup("Fishky", id: "main") {
            ContentView()
                .toolbar(removing: .title)
        }
        .modelContainer(modelContainer)
        WindowGroup("Deck", id: "deck", for: Deck.ID.self) { $deckId in
            if let deckId {
                DeckView.Window(for: deckId)
            } else {
                ContentUnavailableView {
                    Label("Deck not found", systemImage: "xmark")
                } description: {
                    Text("This deck does not exist")
                }
            }
        } //defaultValue: {
        //  TODO:  model.makeNewMessage().id // A new message that your model stores.
        //}
        .modelContainer(modelContainer)
        WindowGroup("Study", id: "study", for: Deck.ID.self) { $deckId in
            if let deckId {
                FullscreenStudyView.Window(for: deckId)
                #if os(macOS)
                    .toolbar(removing: .title)
                    .toolbarBackground(.hidden, for: .windowToolbar)
                #endif
            } else {
                ContentUnavailableView {
                    Label("Deck not found", systemImage: "xmark")
                } description: {
                    Text("This deck does not exist")
                }
            }
        }.defaultSize(width: 600, height: 400)
        
//        .windowToolbarStyle(.unifiedCompact(showsTitle: false))
        .modelContainer(modelContainer)
    }
}
