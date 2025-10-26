import SwiftUI

struct WorkoutPlanView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var savedWorkoutsManager = SavedWorkoutsManager()
    @State private var isGenerating = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showCustomization = false
    @State private var showSaveDialog = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Workout Plan")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    if let plan = appState.currentWorkoutPlan {
                        Text(plan.title)
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.7))
                    } else {
                        Text("No active plan")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                
                // Generate Plan Button
                if appState.currentWorkoutPlan == nil {
                    Button(action: generatePlan) {
                        HStack {
                            if isGenerating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "sparkles")
                                    .font(.title3)
                            }
                            
                            Text(isGenerating ? "Generating..." : "Generate AI Workout Plan")
                                .fontWeight(.semibold)
                        }
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
                    .disabled(isGenerating)
                    .padding(.horizontal, 24)
                }
                
                // Workout Plan Display
                if let plan = appState.currentWorkoutPlan {
                    VStack(alignment: .leading, spacing: 16) {
                        // Plan Info
                        InfoCard(
                            title: "Plan Overview",
                            items: [
                                ("Workouts", "\(plan.workouts.count) per week"),
                                ("Focus", plan.description)
                            ]
                        )
                        .padding(.horizontal, 24)
                        
                        // Action Buttons
                        HStack(spacing: 12) {
                            Button(action: { showCustomization = true }) {
                                HStack {
                                    Image(systemName: "slider.horizontal.3")
                                    Text("Customize")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.6))
                                .cornerRadius(16)
                            }
                            
                            Button(action: { showSaveDialog = true }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.down")
                                    Text("Save")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green.opacity(0.6))
                                .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Workouts List
                        Text("Weekly Schedule")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                        
                        ForEach(plan.workouts) { workout in
                            WorkoutDetailCard(workout: workout)
                                .padding(.horizontal, 24)
                        }
                    }
                }
                
                Spacer(minLength: 100)
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showCustomization) {
            if let plan = appState.currentWorkoutPlan {
                WorkoutCustomizationView(
                    plan: plan,
                    onPlanUpdated: { newPlan in
                        appState.saveWorkoutPlan(newPlan)
                        showCustomization = false
                    }
                )
            }
        }
        .sheet(isPresented: $showSaveDialog) {
            if let plan = appState.currentWorkoutPlan {
                SaveWorkoutDialog(
                    plan: plan,
                    savedWorkoutsManager: savedWorkoutsManager,
                    isPresented: $showSaveDialog
                )
            }
        }
    }
    
    private func generatePlan() {
        guard let profile = appState.userProfile else { return }
        
        isGenerating = true
        
        Task {
            do {
                let plan = try await OpenAIService.shared.generateWorkoutPlan(for: profile)
                await MainActor.run {
                    appState.saveWorkoutPlan(plan)
                    isGenerating = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isGenerating = false
                }
            }
        }
    }
}

struct InfoCard: View {
    let title: String
    let items: [(String, String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(items, id: \.0) { item in
                    HStack {
                        Text(item.0)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        Text(item.1)
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
}

struct WorkoutDetailCard: View {
    let workout: Workout
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(workout.day)
                            .font(.caption)
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)
                        
                        Text(workout.title)
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding()
            }
            
            // Exercises
            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(workout.exercises) { exercise in
                        ExerciseRow(exercise: exercise)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct ExerciseRow: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(exercise.name)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                
                Spacer()
                
                // YouTube Tutorial Button
                if let url = exercise.youtubeSearchURL {
                    Link(destination: url) {
                        HStack(spacing: 4) {
                            Image(systemName: "play.rectangle.fill")
                            Text("Watch")
                        }
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.red.opacity(0.5), lineWidth: 1)
                        )
                    }
                }
            }
            
            HStack(spacing: 16) {
                Label("\(exercise.sets) sets", systemImage: "repeat")
                Label(exercise.reps, systemImage: "number")
                Label("\(exercise.restTime)s rest", systemImage: "timer")
            }
            .font(.caption)
            .foregroundColor(.white.opacity(0.7))
            
            if let notes = exercise.notes {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.blue)
                    .italic()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.1))
        )
    }
}

// MARK: - Workout Customization View

struct WorkoutCustomizationView: View {
    let plan: WorkoutPlan
    let onPlanUpdated: (WorkoutPlan) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var customizationRequest = ""
    @State private var isProcessing = false
    @State private var showWarning = false
    @State private var customizationResponse: CustomizationResponse?
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "0A0E27"), Color(hex: "1A1F3A")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Customize Your Plan")
                            .font(.title.bold())
                            .foregroundColor(.white)
                        
                        Text("Tell us what you'd like to change:")
                            .foregroundColor(.white.opacity(0.7))
                        
                        TextEditor(text: $customizationRequest)
                            .frame(height: 150)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(16)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                        
                        Text("Examples:")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ExampleTag(text: "More focus on push-pull-legs split")
                            ExampleTag(text: "Add more cardio")
                            ExampleTag(text: "Remove leg press, add squats")
                            ExampleTag(text: "Increase upper body focus")
                        }
                        
                        if customizationResponse != nil && !isProcessing {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(customizationResponse?.isHarmful == true ? .orange : .blue)
                                    Text("AI Response:")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                
                                if let explanation = customizationResponse?.explanation {
                                    Text(explanation)
                                        .foregroundColor(.white.opacity(0.8))
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(customizationResponse?.isHarmful == true ? Color.orange.opacity(0.1) : Color.blue.opacity(0.1))
                                        )
                                }
                            }
                        }
                        
                        if isProcessing {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Analyzing your changes...")
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        
                        Button(action: submitCustomization) {
                            Text("Apply Changes")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [.green, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                        }
                        .disabled(customizationRequest.isEmpty || isProcessing)
                        .opacity(customizationRequest.isEmpty || isProcessing ? 0.5 : 1.0)
                    }
                    .padding()
                }
            }
            .navigationTitle("Customize Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
            .alert("⚠️ Safety Warning", isPresented: $showWarning) {
                Button("Proceed Anyway") {
                    if let newPlan = customizationResponse?.modifiedPlan {
                        onPlanUpdated(newPlan)
                        dismiss()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                if let warning = customizationResponse?.warningMessage {
                    Text(warning)
                }
            }
        }
    }
    
    private func submitCustomization() {
        isProcessing = true
        
        Task {
            do {
                let request = CustomizationRequest(request: customizationRequest, currentPlan: plan)
                let response = try await OpenAIService.shared.customizeWorkoutPlan(request)
                
                await MainActor.run {
                    customizationResponse = response
                    isProcessing = false
                    
                    if response.isHarmful {
                        showWarning = true
                    } else {
                        if let newPlan = response.modifiedPlan {
                            onPlanUpdated(newPlan)
                            dismiss()
                        } else {
                            // Plan parsing failed, show explanation only
                            print("Failed to parse modified plan, but AI provided explanation")
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    isProcessing = false
                    print("Error customizing plan: \(error.localizedDescription)")
                    // Show error to user
                    customizationResponse = CustomizationResponse(
                        isHarmful: false,
                        warningMessage: nil,
                        modifiedPlan: nil,
                        explanation: "Sorry, there was an error processing your request. Please try again or be more specific with your changes."
                    )
                }
            }
        }
    }
}

struct ExampleTag: View {
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
            Text(text)
                .foregroundColor(.blue)
        }
        .font(.caption)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.blue.opacity(0.1))
        )
    }
}

// MARK: - Save Workout Dialog

struct SaveWorkoutDialog: View {
    let plan: WorkoutPlan
    @ObservedObject var savedWorkoutsManager: SavedWorkoutsManager
    @Binding var isPresented: Bool
    
    @State private var selectedSlot: Int = 1
    @State private var workoutName: String = ""
    
    private var existingWorkoutInSlot: SavedWorkout? {
        savedWorkoutsManager.savedWorkouts.first { $0.slotNumber == selectedSlot }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                gradientBackground
                
                ScrollView {
                    VStack(spacing: 24) {
                        titleSection
                        nameInputSection
                        slotSelectionSection
                        saveButton
                    }
                    .padding(.top, 40)
                    .padding(.horizontal, 24)
                }
            }
            .navigationTitle("Save Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
    
    private var gradientBackground: some View {
        LinearGradient(
            colors: [Color(hex: "0A0E27"), Color(hex: "1A1F3A")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var titleSection: some View {
        Text("Save Workout Plan")
            .font(.title.bold())
            .foregroundColor(.white)
    }
    
    private var nameInputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Workout Name")
                .font(.headline)
                .foregroundColor(.white)
            
            TextField("e.g., Summer 2024 Plan", text: $workoutName)
                .textFieldStyle(CustomTextFieldStyle())
        }
    }
    
    private var slotSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose a Slot")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                slotButton(slot: 1)
                slotButton(slot: 2)
                slotButton(slot: 3)
            }
        }
    }
    
    private func slotButton(slot: Int) -> some View {
        let existingWorkout = savedWorkoutsManager.savedWorkouts.first { $0.slotNumber == slot }
        
        return Button(action: { selectedSlot = slot }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: selectedSlot == slot ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selectedSlot == slot ? .green : .white.opacity(0.3))
                        Text("Slot \(slot)")
                            .font(.headline)
                            .foregroundColor(.white)
                        if existingWorkout != nil {
                            Text("(Occupied)")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    if let existing = existingWorkout {
                        Text(existing.name)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                        Text("Saved: \(existing.savedDate, style: .date)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedSlot == slot ? Color.green.opacity(0.2) : Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedSlot == slot ? Color.green : Color.white.opacity(0.1), lineWidth: 2)
            )
        }
    }
    
    private var saveButton: some View {
        Button(action: saveWorkout) {
            Text(existingWorkoutInSlot != nil ? "Overwrite Slot \(selectedSlot)" : "Save to Slot \(selectedSlot)")
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.green, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
        }
        .disabled(workoutName.isEmpty)
        .opacity(workoutName.isEmpty ? 0.5 : 1.0)
        .padding(.bottom, 40)
    }
    
    private func saveWorkout() {
        guard !workoutName.isEmpty else { return }
        
        savedWorkoutsManager.saveWorkout(plan, inSlot: selectedSlot, withName: workoutName)
        isPresented = false
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .foregroundColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
    }
}


