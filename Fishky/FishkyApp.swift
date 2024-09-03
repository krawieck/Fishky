//
//  FishkyApp.swift
//  Fishky
//
//  Created by Filip Krawczyk on 18/06/2023.
//

import SwiftUI
import SwiftData

@main
struct FishkyApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Deck.self, Flashcard.self],
                        isAutosaveEnabled: true)
    }
}
