import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentStep = 0
    @State private var name = ""
    @State private var age = ""
    @State private var selectedFitnessLevel: UserProfile.FitnessLevel = .beginner
    @State private var selectedGoals: Set<UserProfile.FitnessGoal> = []
    @State private var restrictions = ""
    @State private var selectedWorkoutTypes: Set<UserProfile.WorkoutType> = []
    @State private var selectedEquipment: Set<UserProfile.Equipment> = []
    @State private var selectedFrequency: UserProfile.WorkoutFrequency = .threeDays
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                colors: [Color(hex: "0A0E27"), Color(hex: "1A1F3A")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress Indicator
                HStack(spacing: 8) {
                    ForEach(0..<7) { index in
                        Capsule()
                            .fill(index <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                
                TabView(selection: $currentStep) {
                    WelcomeStep()
                        .tag(0)
                    
                    NameAgeStep(name: $name, age: $age)
                        .tag(1)
                    
                    FitnessLevelStep(selectedLevel: $selectedFitnessLevel)
                        .tag(2)
                    
                    GoalsStep(selectedGoals: $selectedGoals)
                        .tag(3)
                    
                    WorkoutTypeStep(selectedTypes: $selectedWorkoutTypes, selectedEquipment: $selectedEquipment)
                        .tag(4)
                    
                    WorkoutFrequencyStep(selectedFrequency: $selectedFrequency)
                        .tag(5)
                    
                    RestrictionsStep(restrictions: $restrictions)
                        .tag(6)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Navigation Buttons
                HStack(spacing: 16) {
                    if currentStep > 0 {
                        Button(action: { currentStep -= 1 }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(16)
                        }
                    }
                    
                    Button(action: handleNext) {
                        Text(currentStep == 6 ? "Get Started" : "Continue")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                    }
                    .disabled(!canProceed())
                    .opacity(canProceed() ? 1.0 : 0.5)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func canProceed() -> Bool {
        switch currentStep {
        case 0: return true
        case 1: return !name.isEmpty && !age.isEmpty && Int(age) != nil
        case 2: return true
        case 3: return !selectedGoals.isEmpty
        case 4: return !selectedWorkoutTypes.isEmpty && !selectedEquipment.isEmpty
        case 5: return true
        case 6: return true
        default: return false
        }
    }
    
    private func handleNext() {
        if currentStep < 6 {
            withAnimation {
                currentStep += 1
            }
        } else {
            completeOnboarding()
        }
    }
    
    private func completeOnboarding() {
        let restrictionsList = restrictions.isEmpty ? [] : restrictions.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        let profile = UserProfile(
            name: name,
            age: Int(age) ?? 25,
            fitnessLevel: selectedFitnessLevel,
            goals: Array(selectedGoals),
            restrictions: restrictionsList,
            preferredWorkoutTypes: Array(selectedWorkoutTypes),
            availableEquipment: Array(selectedEquipment),
            workoutFrequency: selectedFrequency
        )
        
        appState.completeOnboarding(with: profile)
    }
}

// MARK: - Onboarding Steps

struct WelcomeStep: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 100))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Welcome to")
                .font(.title2)
                .foregroundColor(.white.opacity(0.7))
            
            Text("RepRight")
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("Your AI-powered personal trainer for perfect form and custom workout plans")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding()
    }
}

struct NameAgeStep: View {
    @Binding var name: String
    @Binding var age: String
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("Let's get to know you")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("This helps us personalize your experience")
                    .foregroundColor(.white.opacity(0.7))
            }
            
            VStack(spacing: 20) {
                CustomTextField(title: "Name", placeholder: "Enter your name", text: $name)
                CustomTextField(title: "Age", placeholder: "Enter your age", text: $age, keyboardType: .numberPad)
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
}

struct FitnessLevelStep: View {
    @Binding var selectedLevel: UserProfile.FitnessLevel
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("What's your fitness level?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Be honest - we'll adjust accordingly")
                    .foregroundColor(.white.opacity(0.7))
            }
            
            VStack(spacing: 12) {
                ForEach(UserProfile.FitnessLevel.allCases, id: \.self) { level in
                    SelectionCard(
                        title: level.rawValue,
                        description: levelDescription(level),
                        isSelected: selectedLevel == level
                    ) {
                        selectedLevel = level
                    }
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
    
    private func levelDescription(_ level: UserProfile.FitnessLevel) -> String {
        switch level {
        case .beginner: return "Just starting out or returning after a break"
        case .intermediate: return "Working out regularly for 6+ months"
        case .advanced: return "Consistent training for 2+ years"
        case .athlete: return "Competitive or professional level"
        }
    }
}

struct GoalsStep: View {
    @Binding var selectedGoals: Set<UserProfile.FitnessGoal>
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("What are your goals?")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Select all that apply")
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 40)
                
                VStack(spacing: 12) {
                    ForEach(UserProfile.FitnessGoal.allCases, id: \.self) { goal in
                        MultiSelectCard(
                            title: goal.rawValue,
                            icon: goalIcon(goal),
                            isSelected: selectedGoals.contains(goal)
                        ) {
                            if selectedGoals.contains(goal) {
                                selectedGoals.remove(goal)
                            } else {
                                selectedGoals.insert(goal)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    private func goalIcon(_ goal: UserProfile.FitnessGoal) -> String {
        switch goal {
        case .weightLoss: return "flame.fill"
        case .muscleGain: return "figure.strengthtraining.traditional"
        case .strength: return "bolt.fill"
        case .endurance: return "heart.fill"
        case .flexibility: return "figure.flexibility"
        case .sports: return "sportscourt.fill"
        case .general: return "figure.walk"
        }
    }
}

struct WorkoutTypeStep: View {
    @Binding var selectedTypes: Set<UserProfile.WorkoutType>
    @Binding var selectedEquipment: Set<UserProfile.Equipment>
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("Preferred Workouts")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("What do you enjoy?")
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 40)
                
                VStack(spacing: 12) {
                    ForEach(UserProfile.WorkoutType.allCases, id: \.self) { type in
                        MultiSelectCard(
                            title: type.rawValue,
                            icon: "checkmark.circle.fill",
                            isSelected: selectedTypes.contains(type)
                        ) {
                            if selectedTypes.contains(type) {
                                selectedTypes.remove(type)
                            } else {
                                selectedTypes.insert(type)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Divider()
                    .background(Color.white.opacity(0.2))
                    .padding(.vertical, 16)
                
                VStack(spacing: 16) {
                    Text("Available Equipment")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 12) {
                    ForEach(UserProfile.Equipment.allCases, id: \.self) { equipment in
                        MultiSelectCard(
                            title: equipment.rawValue,
                            icon: "checkmark.circle.fill",
                            isSelected: selectedEquipment.contains(equipment)
                        ) {
                            if selectedEquipment.contains(equipment) {
                                selectedEquipment.remove(equipment)
                            } else {
                                selectedEquipment.insert(equipment)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

struct WorkoutFrequencyStep: View {
    @Binding var selectedFrequency: UserProfile.WorkoutFrequency
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("How often can you work out?")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Be realistic - we'll optimize your routine")
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                VStack(spacing: 12) {
                    ForEach(UserProfile.WorkoutFrequency.allCases, id: \.self) { frequency in
                        SelectionCard(
                            title: frequency.rawValue,
                            description: frequency.description,
                            isSelected: selectedFrequency == frequency
                        ) {
                            selectedFrequency = frequency
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

struct RestrictionsStep: View {
    @Binding var restrictions: String
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("Any limitations?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Injuries, health conditions, or preferences")
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Optional")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.leading, 8)
                
                TextEditor(text: $restrictions)
                    .frame(height: 150)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(16)
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
                
                Text("e.g., Lower back injury, No jumping exercises")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.leading, 8)
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
}

