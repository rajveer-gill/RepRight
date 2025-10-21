import Foundation

struct UserProfile: Codable {
    let name: String
    let age: Int
    let fitnessLevel: FitnessLevel
    let goals: [FitnessGoal]
    let restrictions: [String]
    let preferredWorkoutTypes: [WorkoutType]
    let availableEquipment: [Equipment]
    
    enum FitnessLevel: String, Codable, CaseIterable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        case athlete = "Athlete"
    }
    
    enum FitnessGoal: String, Codable, CaseIterable {
        case weightLoss = "Weight Loss"
        case muscleGain = "Muscle Gain"
        case strength = "Build Strength"
        case endurance = "Improve Endurance"
        case flexibility = "Increase Flexibility"
        case sports = "Sports Performance"
        case general = "General Fitness"
    }
    
    enum WorkoutType: String, Codable, CaseIterable {
        case weightlifting = "Weightlifting"
        case cardio = "Cardio"
        case hiit = "HIIT"
        case yoga = "Yoga"
        case sports = "Sports Training"
        case calisthenics = "Calisthenics"
        case crossfit = "CrossFit"
    }
    
    enum Equipment: String, Codable, CaseIterable {
        case dumbbells = "Dumbbells"
        case barbell = "Barbell"
        case kettlebell = "Kettlebell"
        case resistanceBands = "Resistance Bands"
        case pullupBar = "Pull-up Bar"
        case bench = "Bench"
        case machine = "Gym Machines"
        case none = "No Equipment"
    }
}

