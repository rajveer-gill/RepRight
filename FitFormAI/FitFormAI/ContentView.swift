import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            if !appState.hasCompletedOnboarding {
                OnboardingView()
            } else {
                MainTabView()
            }
        }
    }
}

