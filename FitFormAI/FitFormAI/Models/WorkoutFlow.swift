import Foundation

// MARK: - Motivational Messages

struct MotivationalMessages {
    static let readyToWorkout: [String] = [
        "Are you ready to be your best self?",
        "Let's crush this workout!",
        "Time to show yourself what you're made of!",
        "Ready to unleash your potential?",
        "Let's make today count!",
        "Time to rise and grind!",
        "Ready to push your limits?",
        "Let's turn effort into results!",
        "Time to be unstoppable!",
        "Ready to dominate this workout?"
    ]
    
    static let duringWorkout: [String] = [
        "YOU GOT THIS!",
        "PUSH HARDER!",
        "DON'T QUIT NOW!",
        "YOU'RE STRONGER!",
        "KEEP GOING!",
        "GIVE IT YOUR ALL!",
        "YOU'RE UNSTOPPABLE!",
        "FIGHT FOR IT!",
        "DIG DEEP!",
        "FINISH STRONG!"
    ]
    
    static let restPeriod: [String] = [
        "Take a little rest before your next set. You earned it 😁",
        "Great work! Take a breather, you've earned it 💪",
        "Nice job! Rest up for the next round 🔥",
        "You're crushing it! Take a moment to recover 🌟",
        "Keep it up! Time to rest and recharge ⭐",
        "Excellent work! Breathe and prepare for more 💪",
        "You're doing great! Rest and come back stronger 🔥",
        "Take a breather, you're making progress 😊",
        "Well done! Time to reset and go again ⚡",
        "Stay focused! Rest now, dominate next 🏆"
    ]
    
    static let timeToStart: [String] = [
        "Time to start the next lift, let's do this 💪🏾",
        "Rest time's up! Let's get back to work! 💪",
        "Ready to crush the next set? Let's go! 🔥",
        "Time to push yourself again! You got this! 💪",
        "Let's keep the momentum going! 💪🏾",
        "Rest is over! Time to dominate! 🔥",
        "Ready to push your limits again? Let's go! 💪",
        "Back to work! Let's make it count! 💪🏾",
        "Time to channel your inner beast! Let's do this! 🔥",
        "Rested and ready! Let's crush this! 💪🏾"
    ]
}

// MARK: - Workout State

enum WorkoutState {
    case ready // Ready to start screen
    case workoutSelection // Choosing which workout
    case activeSet(ActiveSetData) // During a set
    case rest(RestData) // Rest period
    case completed // Workout complete
}

struct ActiveSetData {
    let exercise: Exercise
    let setNumber: Int
    let totalSets: Int
    let workoutStartTime: Date
}

struct RestData {
    let exercise: Exercise
    let nextSetNumber: Int
    let totalSets: Int
    let recommendedRestTime: TimeInterval
    let workoutStartTime: Date
}

struct CurrentWorkoutSession {
    let workout: Workout
    var completedExercises: Set<UUID> = []
    var currentExerciseIndex: Int = 0
    var currentSetNumber: Int = 1
    let startTime: Date
    
    init(workout: Workout) {
        self.workout = workout
        self.startTime = Date()
    }
    
    var hasMoreSets: Bool {
        guard currentExerciseIndex < workout.exercises.count else { return false }
        let exercise = workout.exercises[currentExerciseIndex]
        return currentSetNumber < exercise.sets
    }
    
    var hasMoreExercises: Bool {
        return currentExerciseIndex < workout.exercises.count - 1
    }
    
    var isComplete: Bool {
        return currentExerciseIndex >= workout.exercises.count
    }
    
    mutating func completeSet() {
        currentSetNumber += 1
    }
    
    mutating func moveToNextExercise() {
        if currentExerciseIndex < workout.exercises.count {
            completedExercises.insert(workout.exercises[currentExerciseIndex].id)
        }
        currentExerciseIndex += 1
        currentSetNumber = 1
    }
    
    var currentExercise: Exercise? {
        guard currentExerciseIndex < workout.exercises.count else { return nil }
        return workout.exercises[currentExerciseIndex]
    }
    
    var nextExercise: Exercise? {
        guard currentExerciseIndex + 1 < workout.exercises.count else { return nil }
        return workout.exercises[currentExerciseIndex + 1]
    }
}
