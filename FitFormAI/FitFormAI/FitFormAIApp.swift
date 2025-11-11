import SwiftUI

@main
struct FitFormAIApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var savedWorkoutsManager = SavedWorkoutsManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(savedWorkoutsManager)
                .preferredColorScheme(.dark)
        }
    }
}

