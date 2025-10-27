import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var hasCompletedOnboarding: Bool = false
    @Published var userProfile: UserProfile?
    @Published var currentWorkoutPlan: WorkoutPlan?
    @Published var currentPlanName: String = "" // Name of the active workout plan
    @Published var currentWorkoutDayIndex: Int = 0 // Which day of the workout plan we're on
    @Published var streakCount: Int = 0 // User's workout streak
    @Published var workoutMinutesToday: Int = 0 // Minutes spent working out today
    @Published var lastWorkoutDate: Date? = nil // Last date a workout was completed
    @Published var completedWorkoutToday: Bool = false // If today's workout is completed
    @Published var hasAttemptedWorkoutToday: Bool = false // If user has attempted at least one set today
    @Published var isStreakBroken: Bool = false // If the streak was just broken
    @Published var isLoading: Bool = false
    
    init() {
        // Load saved state from UserDefaults
        loadState()
        
        // Check if it's a new day
        checkNewDay()
        
        // Set up timer to check for new day
        setupMidnightTimer()
    }
    
    private var midnightTimer: Timer? = nil
    
    private func setupMidnightTimer() {
        let calendar = Calendar.current
        let now = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
        let startOfTomorrow = calendar.startOfDay(for: tomorrow)
        let timeUntilMidnight = startOfTomorrow.timeIntervalSince(now)
        
        Timer.scheduledTimer(withTimeInterval: timeUntilMidnight, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            
            // Check if today is a scheduled workout day (only if plan has fewer than 7 workouts)
            let isWorkoutDay = self.isTodayScheduledWorkoutDay()
            
            if isWorkoutDay {
                // Check if user attempted workout on a scheduled workout day
                if self.hasAttemptedWorkoutToday {
                    // User attempted workout - increment streak
                    self.streakCount += 1
                    self.lastWorkoutDate = Date()
                    self.checkNewDay()
                } else {
                    // No attempt on a workout day - break streak
                    if self.streakCount > 0 {
                        self.isStreakBroken = true
                        self.streakCount = 0
                    }
                }
            }
            // If not a workout day (rest day), don't change the streak at all
            
            // Reset for next day
            self.hasAttemptedWorkoutToday = false
            self.completedWorkoutToday = false
            self.workoutMinutesToday = 0
            self.workoutStartTime = nil // Clear workout start time for new day
            
            // Advance to the next day's workout
            if let plan = self.currentWorkoutPlan, self.currentWorkoutDayIndex < plan.workouts.count - 1 {
                self.currentWorkoutDayIndex += 1
            } else if let plan = self.currentWorkoutPlan {
                self.currentWorkoutDayIndex = 0
            }
            
            self.saveState()
            
            // Schedule next midnight
            self.setupMidnightTimer()
        }
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
    
    // Exercise set progress persistence
    @Published var exerciseSetProgress: [UUID: Int] = [:]
    
    // Workout start time for session continuity
    var workoutStartTime: Date? {
        get {
            if let timeStamp = UserDefaults.standard.object(forKey: "currentWorkoutStartTime") as? Date {
                return timeStamp
            }
            return nil
        }
        set {
            if let time = newValue {
                UserDefaults.standard.set(time, forKey: "currentWorkoutStartTime")
            } else {
                UserDefaults.standard.removeObject(forKey: "currentWorkoutStartTime")
            }
        }
    }
    
    private func saveState() {
        UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(currentPlanName, forKey: "currentPlanName")
        UserDefaults.standard.set(currentWorkoutDayIndex, forKey: "currentWorkoutDayIndex")
        UserDefaults.standard.set(streakCount, forKey: "streakCount")
        UserDefaults.standard.set(workoutMinutesToday, forKey: "workoutMinutesToday")
        UserDefaults.standard.set(completedWorkoutToday, forKey: "completedWorkoutToday")
        UserDefaults.standard.set(hasAttemptedWorkoutToday, forKey: "hasAttemptedWorkoutToday")
        UserDefaults.standard.set(isStreakBroken, forKey: "isStreakBroken")
        
        // Save exercise set progress
        let progressArray = exerciseSetProgress.map { ExerciseProgress(exerciseId: $0.key.uuidString, completedSets: $0.value) }
        if let encoded = try? JSONEncoder().encode(progressArray) {
            UserDefaults.standard.set(encoded, forKey: "exerciseSetProgress")
        }
        
        if let lastDate = lastWorkoutDate {
            UserDefaults.standard.set(lastDate, forKey: "lastWorkoutDate")
        }
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
        currentWorkoutDayIndex = UserDefaults.standard.integer(forKey: "currentWorkoutDayIndex")
        streakCount = UserDefaults.standard.integer(forKey: "streakCount")
        workoutMinutesToday = UserDefaults.standard.integer(forKey: "workoutMinutesToday")
        completedWorkoutToday = UserDefaults.standard.bool(forKey: "completedWorkoutToday")
        hasAttemptedWorkoutToday = UserDefaults.standard.bool(forKey: "hasAttemptedWorkoutToday")
        lastWorkoutDate = UserDefaults.standard.object(forKey: "lastWorkoutDate") as? Date
        isStreakBroken = UserDefaults.standard.bool(forKey: "isStreakBroken")
        
        // Load exercise set progress
        if let data = UserDefaults.standard.data(forKey: "exerciseSetProgress"),
           let decoded = try? JSONDecoder().decode([ExerciseProgress].self, from: data) {
            exerciseSetProgress = [:]
            for item in decoded {
                if let id = UUID(uuidString: item.exerciseId) {
                    exerciseSetProgress[id] = item.completedSets
                }
            }
        }
        if let data = UserDefaults.standard.data(forKey: "userProfile"),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = profile
        }
        if let data = UserDefaults.standard.data(forKey: "currentWorkoutPlan"),
           let plan = try? JSONDecoder().decode(WorkoutPlan.self, from: data) {
            currentWorkoutPlan = plan
        }
    }
    
    private func checkNewDay() {
        let calendar = Calendar.current
        let today = Date()
        
        guard let lastDate = lastWorkoutDate else { return }
        
        // If last workout date is not today
        if !calendar.isDate(lastDate, inSameDayAs: today) {
            completedWorkoutToday = false
            
            // Check if streak should be broken
            if streakCount > 0 {
                isStreakBroken = true
                streakCount = 0
            }
            
            saveState()
        }
    }
    
    func completeWorkout(minutes: Int = 0) {
        completedWorkoutToday = true
        workoutMinutesToday = minutes
        // Note: Streak is incremented by timer when user attempts workout
        saveState()
    }
    
    func attemptWorkout() {
        hasAttemptedWorkoutToday = true
        
        // Increment streak immediately when user completes their first set
        if !hasAttemptedWorkoutToday && isTodayScheduledWorkoutDay() {
            streakCount += 1
            lastWorkoutDate = Date()
        }
        
        saveState()
    }
    
    func dismissStreakBrokenMessage() {
        isStreakBroken = false
        saveState()
    }
    
    func getCurrentWorkout() -> Workout? {
        guard let plan = currentWorkoutPlan else { return nil }
        guard !plan.workouts.isEmpty else { return nil }
        
        // Get the current day of week (1 = Sunday, 2 = Monday, ..., 7 = Saturday)
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        
        // Convert to 0-based index (0 = Sunday, 1 = Monday, ..., 6 = Saturday)
        let dayIndex = weekday - 1
        
        // If the plan has workouts for all 7 days, return the workout for today
        if plan.workouts.count == 7 {
            guard dayIndex < plan.workouts.count else { return plan.workouts.first }
            return plan.workouts[dayIndex]
        }
        
        // Otherwise, return the first workout (which will be rotated by the midnight timer)
        return plan.workouts.first
    }
    
    func saveExerciseProgress() {
        // Save just the exercise set progress
        let progressArray = exerciseSetProgress.map { ExerciseProgress(exerciseId: $0.key.uuidString, completedSets: $0.value) }
        if let encoded = try? JSONEncoder().encode(progressArray) {
            UserDefaults.standard.set(encoded, forKey: "exerciseSetProgress")
        }
    }
    
    func saveWorkoutMinutes() {
        // Save just the workout minutes
        UserDefaults.standard.set(workoutMinutesToday, forKey: "workoutMinutesToday")
    }
    
    func clearWorkoutPlan() {
        currentWorkoutPlan = nil
        UserDefaults.standard.removeObject(forKey: "currentWorkoutPlan")
    }
    
    func saveUserProfile() {
        if let profile = userProfile, let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: "userProfile")
        }
    }
    
    // Helper function to determine if today is a scheduled workout day
    private func isTodayScheduledWorkoutDay() -> Bool {
        guard let plan = currentWorkoutPlan else { return true } // Default to true if no plan
        
        // If plan has 7 workouts (daily plan), every day is a workout day
        if plan.workouts.count == 7 {
            return true
        }
        
        // For limited plans (e.g., 3, 4, 5 days per week), only check on days with workouts
        // Get today's workout
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        let dayIndex = weekday - 1
        
        // Check if we have a workout scheduled for today
        // Since limited plans don't use day-of-week mapping, check if currentWorkoutDayIndex matches a workout day
        return currentWorkoutDayIndex < plan.workouts.count
    }
}

// Helper struct for exercise progress persistence
struct ExerciseProgress: Codable {
    let exerciseId: String
    let completedSets: Int
}

