import SwiftUI

@main
struct FlashcardsApp: App {
    @StateObject private var store = DeckStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
