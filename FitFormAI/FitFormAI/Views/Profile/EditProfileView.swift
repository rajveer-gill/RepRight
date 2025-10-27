import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var age = ""
    @State private var selectedFitnessLevel: UserProfile.FitnessLevel = .beginner
    @State private var selectedGoals: Set<UserProfile.FitnessGoal> = []
    @State private var restrictions = ""
    @State private var selectedWorkoutTypes: Set<UserProfile.WorkoutType> = []
    @State private var selectedEquipment: Set<UserProfile.Equipment> = []
    @State private var selectedFrequency: UserProfile.WorkoutFrequency = .threeDays
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color(hex: "0A0E27"), Color(hex: "1A1F3A")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Name Section
                        SectionView(title: "Name") {
                            TextField("Enter your name", text: $name)
                                .textFieldStyle(EditTextFieldStyle())
                        }
                        
                        // Age Section
                        SectionView(title: "Age") {
                            TextField("Enter your age", text: $age)
                                .keyboardType(.numberPad)
                                .textFieldStyle(EditTextFieldStyle())
                        }
                        
                        // Fitness Level Section
                        SectionView(title: "Fitness Level") {
                            VStack(spacing: 12) {
                                ForEach(UserProfile.FitnessLevel.allCases, id: \.self) { level in
                                    Button(action: { selectedFitnessLevel = level }) {
                                        FitnessLevelCard(
                                            level: level,
                                            isSelected: selectedFitnessLevel == level
                                        )
                                    }
                                }
                            }
                        }
                        
                        // Goals Section
                        SectionView(title: "Goals") {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(UserProfile.FitnessGoal.allCases, id: \.self) { goal in
                                    Button(action: {
                                        if selectedGoals.contains(goal) {
                                            selectedGoals.remove(goal)
                                        } else {
                                            selectedGoals.insert(goal)
                                        }
                                    }) {
                                        GoalCard(goal: goal, isSelected: selectedGoals.contains(goal))
                                    }
                                }
                            }
                        }
                        
                        // Workout Types Section
                        SectionView(title: "Preferred Workout Types") {
                            VStack(spacing: 12) {
                                ForEach(UserProfile.WorkoutType.allCases, id: \.self) { type in
                                    Button(action: {
                                        if selectedWorkoutTypes.contains(type) {
                                            selectedWorkoutTypes.remove(type)
                                        } else {
                                            selectedWorkoutTypes.insert(type)
                                        }
                                    }                                    ) {
                                        EditSelectionCard(
                                            title: type.rawValue,
                                            isSelected: selectedWorkoutTypes.contains(type)
                                        )
                                    }
                                }
                            }
                        }
                        
                        // Equipment Section
                        SectionView(title: "Available Equipment") {
                            VStack(spacing: 12) {
                                ForEach(UserProfile.Equipment.allCases, id: \.self) { equipment in
                                    Button(action: {
                                        if selectedEquipment.contains(equipment) {
                                            selectedEquipment.remove(equipment)
                                        } else {
                                            selectedEquipment.insert(equipment)
                                        }
                                    }                                    ) {
                                        EditSelectionCard(
                                            title: equipment.rawValue,
                                            isSelected: selectedEquipment.contains(equipment)
                                        )
                                    }
                                }
                            }
                        }
                        
                        // Workout Frequency Section
                        SectionView(title: "Workout Frequency") {
                            VStack(spacing: 12) {
                                ForEach(UserProfile.WorkoutFrequency.allCases, id: \.self) { frequency in
                                    Button(action: { selectedFrequency = frequency }) {
                                        FrequencyCard(
                                            frequency: frequency,
                                            isSelected: selectedFrequency == frequency
                                        )
                                    }
                                }
                            }
                        }
                        
                        // Restrictions Section
                        SectionView(title: "Restrictions or Injuries") {
                            TextEditor(text: $restrictions)
                                .frame(minHeight: 100)
                                .padding(12)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        }
                        
                        // Save Button
                        Button(action: saveProfile) {
                            Text("Save Changes")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .onAppear {
            loadCurrentProfile()
        }
    }
    
    private func loadCurrentProfile() {
        guard let profile = appState.userProfile else { return }
        
        name = profile.name
        age = String(profile.age)
        selectedFitnessLevel = profile.fitnessLevel
        selectedGoals = Set(profile.goals)
        restrictions = profile.restrictions.joined(separator: ", ")
        selectedWorkoutTypes = Set(profile.preferredWorkoutTypes)
        selectedEquipment = Set(profile.availableEquipment)
        selectedFrequency = profile.workoutFrequency
    }
    
    private func saveProfile() {
        guard !name.isEmpty, !age.isEmpty, let ageInt = Int(age) else { return }
        guard !selectedGoals.isEmpty, !selectedWorkoutTypes.isEmpty, !selectedEquipment.isEmpty else { return }
        
        let restrictionsList = restrictions.isEmpty ? [] : restrictions.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        let updatedProfile = UserProfile(
            name: name,
            age: ageInt,
            fitnessLevel: selectedFitnessLevel,
            goals: Array(selectedGoals),
            restrictions: restrictionsList,
            preferredWorkoutTypes: Array(selectedWorkoutTypes),
            availableEquipment: Array(selectedEquipment),
            workoutFrequency: selectedFrequency
        )
        
        appState.userProfile = updatedProfile
        appState.saveUserProfile()
        dismiss()
    }
}

// MARK: - Supporting Views

struct SectionView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            content
        }
    }
}

struct EditTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .foregroundColor(.white)
    }
}

struct FitnessLevelCard: View {
    let level: UserProfile.FitnessLevel
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Text(level.rawValue)
                .foregroundColor(.white)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.2) : Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
        )
    }
}

struct GoalCard: View {
    let goal: UserProfile.FitnessGoal
    let isSelected: Bool
    
    var body: some View {
        Text(goal.rawValue)
            .font(.subheadline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
            )
    }
}

struct EditSelectionCard: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.2) : Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
        )
    }
}

struct FrequencyCard: View {
    let frequency: UserProfile.WorkoutFrequency
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(frequency.rawValue)
                    .foregroundColor(.white)
                    .font(.body)
                Text(frequency.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.2) : Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
        )
    }
}

