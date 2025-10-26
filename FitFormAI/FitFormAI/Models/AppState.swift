import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var hasCompletedOnboarding: Bool = false
    @Published var userProfile: UserProfile?
    @Published var currentWorkoutPlan: WorkoutPlan?
    @Published var currentPlanName: String = "" // Name of the active workout plan
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
    
    func saveWorkoutPlan(_ plan: WorkoutPlan) {
        self.currentWorkoutPlan = plan
        saveState()
    }
    
    private func saveState() {
        UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(currentPlanName, forKey: "currentPlanName")
        if let profile = userProfile {
            if let encoded = try? JSONEncoder().encode(profile) {
                UserDefaults.standard.set(encoded, forKey: "userProfile")
            }
        }
        if let plan = currentWorkoutPlan {
            if let encoded = try? JSONEncoder().encode(plan) {
                UserDefaults.standard.set(encoded, forKey: "currentWorkoutPlan")
            }
        }
    }
    
    private func loadState() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        currentPlanName = UserDefaults.standard.string(forKey: "currentPlanName") ?? ""
        if let data = UserDefaults.standard.data(forKey: "userProfile"),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = profile
        }
        if let data = UserDefaults.standard.data(forKey: "currentWorkoutPlan"),
           let plan = try? JSONDecoder().decode(WorkoutPlan.self, from: data) {
            currentWorkoutPlan = plan
        }
    }
    
    func clearWorkoutPlan() {
        currentWorkoutPlan = nil
        UserDefaults.standard.removeObject(forKey: "currentWorkoutPlan")
    }
}

