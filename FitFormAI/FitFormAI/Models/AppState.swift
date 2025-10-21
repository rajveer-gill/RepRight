import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var hasCompletedOnboarding: Bool = false
    @Published var userProfile: UserProfile?
    @Published var currentWorkoutPlan: WorkoutPlan?
    @Published var isLoading: Bool = false
    
    init() {
        // Load saved state from UserDefaults
        loadState()
    }
    
    func completeOnboarding(with profile: UserProfile) {
        self.userProfile = profile
        self.hasCompletedOnboarding = true
        saveState()
    }
    
    private func saveState() {
        UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        if let profile = userProfile {
            if let encoded = try? JSONEncoder().encode(profile) {
                UserDefaults.standard.set(encoded, forKey: "userProfile")
            }
        }
    }
    
    private func loadState() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        if let data = UserDefaults.standard.data(forKey: "userProfile"),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = profile
        }
    }
}

