import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var savedWorkoutsManager: SavedWorkoutsManager
    @Binding var selectedTab: Int
    @State private var showWorkoutSelector = false
    @State private var selectedSavedWorkout: SavedWorkout?
    @State private var showWorkoutFlow = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome back,")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(appState.userProfile?.name ?? "Champion")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                
                // Quick Stats
                StatCard(icon: "flame.fill", title: "Streak", value: "\(appState.streakCount) days", color: .orange)
                    .padding(.horizontal, 24)
                
                // Today's Workout Card
                if let workout = appState.getCurrentWorkout() {
                    VStack(alignment: .leading, spacing: 16) {
                        // Plan Name Header
                        if !appState.currentPlanName.isEmpty {
                            Text(appState.currentPlanName)
                                .font(.title3.bold())
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.orange, .red],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .padding(.horizontal, 24)
                                .padding(.bottom, -8)
                        }
                        
                        HStack {
                            Text("Today's Workout")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: { showWorkoutSelector = true }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "square.grid.2x2")
                                    Text("Switch Plan")
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        Button(action: {
                            if !appState.completedWorkoutToday {
                                showWorkoutFlow = true
                            }
                        }) {
                            WorkoutCard(workout: workout, isCompleted: appState.completedWorkoutToday)
                        }
                        .padding(.horizontal, 24)
                        .disabled(appState.completedWorkoutToday)
                        .opacity(appState.completedWorkoutToday ? 0.5 : 1.0)
                    }
                }
                
                // Quick Actions
                VStack(alignment: .leading, spacing: 16) {
                    Text("Quick Actions")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                    
                    VStack(spacing: 12) {
                        QuickActionButton(
                            icon: "sparkles",
                            title: "Generate New Plan",
                            subtitle: "AI-powered custom workout",
                            gradient: [Color.blue, Color.purple],
                            action: { selectedTab = 1 }
                        )
                        
                        QuickActionButton(
                            icon: "video.fill",
                            title: "Check Your Form",
                            subtitle: "Upload or record video",
                            gradient: [Color.purple, Color.pink],
                            action: { selectedTab = 2 }
                        )
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer(minLength: 100)
            }
        }
        .sheet(isPresented: $showWorkoutSelector) {
            WorkoutSelectorView(
                savedWorkoutsManager: savedWorkoutsManager,
                selectedWorkout: $selectedSavedWorkout,
                isPresented: $showWorkoutSelector,
                onWorkoutSelected: { savedWorkout in
                    appState.saveWorkoutPlan(savedWorkout.workoutPlan)
                    appState.currentPlanName = savedWorkout.name
                    selectedSavedWorkout = savedWorkout
                    showWorkoutSelector = false
                }
            )
        }
        .fullScreenCover(isPresented: $showWorkoutFlow) {
            WorkoutFlowView(isPresented: $showWorkoutFlow)
        }
        .alert("Your Streak Was Broken 💔", isPresented: $appState.isStreakBroken) {
            Button("Get Back On Track", role: .cancel) {
                appState.dismissStreakBrokenMessage()
            }
        } message: {
            Text("Consistency is the key to reaching your fitness goals. Every day counts! Let's start fresh and build that streak again. You've got this! 💪")
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3.bold())
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct WorkoutCard: View {
    let workout: Workout
    let isCompleted: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if isCompleted {
                        Text("COMPLETED")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    
                    Text(workout.day)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                    
                    Text(workout.title)
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .strikethrough(isCompleted)
                }
                
                Spacer()
                
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "play.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(isCompleted ? .green : .blue)
            }
            
            HStack(spacing: 16) {
                Label("\(workout.exercises.count) exercises", systemImage: "list.bullet")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Label("\(workout.estimatedDuration) min", systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let gradient: [Color]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(gradient[0].opacity(0.2))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding()
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
}

// MARK: - Workout Selector

struct WorkoutSelectorView: View {
    @ObservedObject var savedWorkoutsManager: SavedWorkoutsManager
    @Binding var selectedWorkout: SavedWorkout?
    @Binding var isPresented: Bool
    let onWorkoutSelected: (SavedWorkout) -> Void
    
    // Computed property to ensure workouts are always sorted by slot number
    private var sortedWorkouts: [SavedWorkout] {
        savedWorkoutsManager.savedWorkouts.sorted { $0.slotNumber < $1.slotNumber }
    }
    
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
                    VStack(spacing: 24) {
                        if savedWorkoutsManager.savedWorkouts.isEmpty {
                            emptyStateView
                        } else {
                            VStack(spacing: 16) {
                                Text("Switch Workout Plan")
                                    .font(.title.bold())
                                    .foregroundColor(.white)
                                
                                ForEach(sortedWorkouts) { savedWorkout in
                                    SavedWorkoutCard(savedWorkout: savedWorkout) {
                                        onWorkoutSelected(savedWorkout)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.top, 40)
                }
            }
            .navigationTitle("Select Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.3))
            
            Text("No Saved Workouts")
                .font(.title2)
                .foregroundColor(.white)
            
            Text("Save a workout plan to switch between different routines")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 100)
    }
}

struct SavedWorkoutCard: View {
    let savedWorkout: SavedWorkout
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "bookmark.fill")
                                .foregroundColor(.blue)
                            Text(savedWorkout.name)
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        Text("Slot \(savedWorkout.slotNumber)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text(savedWorkout.savedDate, style: .date)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.3))
                }
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                HStack(spacing: 16) {
                    Label("\(savedWorkout.workoutPlan.workouts.count) workouts", systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
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
}

