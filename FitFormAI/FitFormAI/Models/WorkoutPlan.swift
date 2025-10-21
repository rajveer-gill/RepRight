import Foundation

struct WorkoutPlan: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String
    let durationWeeks: Int
    let workouts: [Workout]
    let createdAt: Date
    
    init(id: UUID = UUID(), title: String, description: String, durationWeeks: Int, workouts: [Workout], createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.description = description
        self.durationWeeks = durationWeeks
        self.workouts = workouts
        self.createdAt = createdAt
    }
}

struct Workout: Codable, Identifiable {
    let id: UUID
    let day: String
    let title: String
    let exercises: [Exercise]
    let estimatedDuration: Int // in minutes
    
    init(id: UUID = UUID(), day: String, title: String, exercises: [Exercise], estimatedDuration: Int) {
        self.id = id
        self.day = day
        self.title = title
        self.exercises = exercises
        self.estimatedDuration = estimatedDuration
    }
}

struct Exercise: Codable, Identifiable {
    let id: UUID
    let name: String
    let sets: Int
    let reps: String
    let restTime: Int // in seconds
    let notes: String?
    let muscleGroups: [String]
    let difficulty: String
    
    init(id: UUID = UUID(), name: String, sets: Int, reps: String, restTime: Int, notes: String? = nil, muscleGroups: [String], difficulty: String) {
        self.id = id
        self.name = name
        self.sets = sets
        self.reps = reps
        self.restTime = restTime
        self.notes = notes
        self.muscleGroups = muscleGroups
        self.difficulty = difficulty
    }
}

