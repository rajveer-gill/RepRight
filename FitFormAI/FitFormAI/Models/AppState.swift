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
    @Published var accumulatedWorkoutSecondsToday: Int = 0 // Paused time in seconds accumulated today
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
            self.accumulatedWorkoutSecondsToday = 0
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
        UserDefaults.standard.set(accumulatedWorkoutSecondsToday, forKey: "accumulatedWorkoutSecondsToday")
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
        accumulatedWorkoutSecondsToday = UserDefaults.standard.integer(forKey: "accumulatedWorkoutSecondsToday")
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
        
        // Always ensure the session timer is scoped to the current day.
        // If a persisted workout start time is from a previous day, clear it
        // and reset the minutes accumulator so time does not carry over.
        if let start = workoutStartTime, !calendar.isDate(start, inSameDayAs: today) {
            workoutStartTime = nil
            workoutMinutesToday = 0
            accumulatedWorkoutSecondsToday = 0
        }
        
        // If we have a last workout date saved and it's not today, clear daily flags
        if let lastDate = lastWorkoutDate, !calendar.isDate(lastDate, inSameDayAs: today) {
            completedWorkoutToday = false
            hasAttemptedWorkoutToday = false
            
            // Streak break handling is managed elsewhere (midnight logic),
            // but if the app launches after a date change, ensure flags are consistent.
            saveState()
        }
    }
    
    func completeWorkout(minutes: Int = 0) {
        completedWorkoutToday = true
        workoutMinutesToday = minutes
        accumulatedWorkoutSecondsToday = minutes * 60
        // Note: Streak is incremented by timer when user attempts workout
        saveState()
    }
    
    func attemptWorkout() {
        let wasFirstAttempt = !hasAttemptedWorkoutToday
        hasAttemptedWorkoutToday = true
        
        // Increment streak immediately when user completes their first set
        if wasFirstAttempt && isTodayScheduledWorkoutDay() {
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
        
        // If the plan has workouts for all 7 days, choose the correct mapping
        if plan.workouts.count == 7 {
            let index = computeTodayIndex(for: plan)
            guard index < plan.workouts.count else { return plan.workouts.first }
            return plan.workouts[index]
        }
        
        // Otherwise, return the first workout (which will be rotated by the midnight timer)
        return plan.workouts.first
    }

    // Determine today's index depending on whether the plan starts on Sunday or Monday
    private func computeTodayIndex(for plan: WorkoutPlan) -> Int {
        // Calendar.weekday: 1=Sunday ... 7=Saturday
        let weekday = Calendar.current.component(.weekday, from: Date())
        let sundayBasedIndex = weekday - 1 // 0..6 where 0=Sunday
        
        // Detect if plan is Monday-first by inspecting the first day's title/label
        // Many AI plans start with Monday. If so, shift mapping so Monday=0
        if let firstDay = plan.workouts.first?.day.lowercased(), firstDay.hasPrefix("mon") {
            // Convert Sunday-based (0..6) to Monday-based (0..6 where 0=Mon)
            // mondayIndex = (weekday + 5) % 7
            return (weekday + 5) % 7
        }
        
        return sundayBasedIndex
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
        UserDefaults.standard.set(accumulatedWorkoutSecondsToday, forKey: "accumulatedWorkoutSecondsToday")
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
    
    // Pause/resume helpers for total workout timer
    func pauseWorkoutTimer() {
        guard let start = workoutStartTime else { return }
        let elapsed = Int(Date().timeIntervalSince(start))
        accumulatedWorkoutSecondsToday += max(0, elapsed)
        workoutMinutesToday = accumulatedWorkoutSecondsToday / 60
        workoutStartTime = nil
        saveWorkoutMinutes()
    }
    
    func resumeWorkoutTimerIfNeeded() {
        // Only start a live session timer if not already running
        if workoutStartTime == nil {
            workoutStartTime = Date()
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

