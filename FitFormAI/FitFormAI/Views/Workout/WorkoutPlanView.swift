import SwiftUI

struct WorkoutPlanView: View {
    @EnvironmentObject var appState: AppState
    @State private var isGenerating = false
    @State private var showError = false
    @State private var errorMessage = ""
    
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
                                ("Duration", "\(plan.durationWeeks) weeks"),
                                ("Workouts", "\(plan.workouts.count) per week"),
                                ("Focus", plan.description)
                            ]
                        )
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
    }
    
    private func generatePlan() {
        guard let profile = appState.userProfile else { return }
        
        isGenerating = true
        
        Task {
            do {
                let plan = try await OpenAIService.shared.generateWorkoutPlan(for: profile)
                await MainActor.run {
                    appState.currentWorkoutPlan = plan
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
            Text(exercise.name)
                .font(.subheadline.bold())
                .foregroundColor(.white)
            
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

