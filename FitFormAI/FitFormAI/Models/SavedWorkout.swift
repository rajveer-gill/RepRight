import Foundation

struct SavedWorkout: Codable, Identifiable {
    let id: UUID
    let workoutPlan: WorkoutPlan
    let savedDate: Date
    let slotNumber: Int // 1, 2, or 3
    let name: String // Custom name for the workout
    
    init(id: UUID = UUID(), workoutPlan: WorkoutPlan, savedDate: Date = Date(), slotNumber: Int, name: String) {
        self.id = id
        self.workoutPlan = workoutPlan
        self.savedDate = savedDate
        self.slotNumber = slotNumber
        self.name = name
    }
}

class SavedWorkoutsManager: ObservableObject {
    @Published var savedWorkouts: [SavedWorkout] = []
    
    private let maxSlots = 3
    private let savedWorkoutsKey = "SavedWorkouts"
    
    init() {
        loadSavedWorkouts()
    }
    
    func saveWorkout(_ workout: WorkoutPlan, inSlot slot: Int, withName name: String) {
        // Remove existing workout in that slot if any
        savedWorkouts.removeAll { $0.slotNumber == slot }
        
        // Add new saved workout
        let savedWorkout = SavedWorkout(workoutPlan: workout, slotNumber: slot, name: name)
        savedWorkouts.append(savedWorkout)
        
        // Sort by slot number to ensure proper order
        savedWorkouts.sort { $0.slotNumber < $1.slotNumber }
        
        // Ensure we don't exceed max slots
        savedWorkouts = Array(savedWorkouts.suffix(maxSlots))
        
        saveWorkouts()
    }
    
    func deleteWorkout(atSlot slot: Int) {
        savedWorkouts.removeAll { $0.slotNumber == slot }
        saveWorkouts()
    }
    
    func loadWorkout(fromSlot slot: Int) -> SavedWorkout? {
        return savedWorkouts.first { $0.slotNumber == slot }
    }
    
    func getAvailableSlots() -> [Int] {
        let usedSlots = Set(savedWorkouts.map { $0.slotNumber })
        return Array(1...maxSlots).filter { !usedSlots.contains($0) }
    }
    
    func getAllSlots() -> [(slot: Int, workout: SavedWorkout?)] {
        return (1...maxSlots).map { slot in
            (slot: slot, workout: savedWorkouts.first { $0.slotNumber == slot })
        }
    }
    
    private func saveWorkouts() {
        if let encoded = try? JSONEncoder().encode(savedWorkouts) {
            UserDefaults.standard.set(encoded, forKey: savedWorkoutsKey)
        }
    }
    
    private func loadSavedWorkouts() {
        if let data = UserDefaults.standard.data(forKey: savedWorkoutsKey),
           let workouts = try? JSONDecoder().decode([SavedWorkout].self, from: data) {
            savedWorkouts = workouts.sorted { $0.slotNumber < $1.slotNumber }
        }
    }
    
    func deleteAllSavedWorkouts() {
        savedWorkouts.removeAll()
        saveWorkouts()
    }
}

