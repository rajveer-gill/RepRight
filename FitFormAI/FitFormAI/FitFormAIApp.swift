import SwiftUI
import UIKit

@main
struct FitFormAIApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var securityManager = SecurityManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(securityManager)
                .preferredColorScheme(.dark)
                .onAppear {
                    // Request authentication on app launch
                    if securityManager.isLocked || !securityManager.isAuthenticated {
                        securityManager.unlockApp()
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    // Lock app when it goes to background
                    securityManager.lockApp()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    // Request authentication when app becomes active
                    if securityManager.isLocked {
                        securityManager.unlockApp()
                    }
                }
        }
    }
}

