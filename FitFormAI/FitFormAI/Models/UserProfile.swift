import Foundation

struct UserProfile: Codable {
    let name: String
    let age: Int
    let fitnessLevel: FitnessLevel
    let goals: [FitnessGoal]
    let restrictions: [String]
    let preferredWorkoutTypes: [WorkoutType]
    let availableEquipment: [Equipment]
    let workoutFrequency: WorkoutFrequency
    
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
    
    enum WorkoutFrequency: String, Codable, CaseIterable {
        case twoDays = "2 days per week"
        case threeDays = "3 days per week"
        case fourDays = "4 days per week"
        case fiveDays = "5 days per week"
        case sixDays = "6 days per week"
        case sevenDays = "Every day"
        
        var daysPerWeek: Int {
            switch self {
            case .twoDays: return 2
            case .threeDays: return 3
            case .fourDays: return 4
            case .fiveDays: return 5
            case .sixDays: return 6
            case .sevenDays: return 7
            }
        }
        
        var description: String {
            switch self {
            case .sevenDays:
                return "I can work out every day, but prefer active recovery and lighter sessions"
            default:
                return "I can dedicate this many days per week to structured workouts"
            }
        }
    }
}

