import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var securityManager: SecurityManager
    
    var body: some View {
        ZStack {
            if !appState.hasCompletedOnboarding {
                OnboardingView()
            } else {
                if securityManager.isLocked {
                    LockedView()
                } else {
                    MainTabView()
                }
            }
        }
    }
}

