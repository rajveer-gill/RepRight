import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var savedWorkoutsManager: SavedWorkoutsManager
    @Binding var selectedTab: Int
    @State private var showWorkoutSelector = false
    @State private var selectedSavedWorkout: SavedWorkout?
    @State private var showWorkoutFlow = false
    @State private var showWeeklyPlan = false
    
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
                        
                        WorkoutCard(
                            workout: workout,
                            isCompleted: appState.completedWorkoutToday,
                            onPlay: {
                                if !appState.completedWorkoutToday {
                                    showWorkoutFlow = true
                                }
                            },
                            onOpenPlan: {
                                showWeeklyPlan = true
                            }
                        )
                        .padding(.horizontal, 24)
                        .opacity(appState.completedWorkoutToday ? 0.9 : 1.0)
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
        .sheet(isPresented: $showWeeklyPlan) {
            if let plan = appState.currentWorkoutPlan {
                WeeklyPlanBreakdownView(plan: plan)
                    .environmentObject(appState)
            }
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
    let onPlay: () -> Void
    let onOpenPlan: () -> Void
    
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
                
                Button(action: onPlay) {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "play.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(isCompleted ? .green : .blue)
                }
                .disabled(isCompleted)
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
        .contentShape(Rectangle())
        .onTapGesture { onOpenPlan() }
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

// Fallback local definition so the sheet resolves even if the separate file isn't included in the target
struct WeeklyPlanBreakdownView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    let plan: WorkoutPlan
    @State private var selectedIndex: Int = 0
    
    private var highlightIndex: Int {
        if plan.workouts.count == 7 {
            let weekday = Calendar.current.component(.weekday, from: Date())
            let firstDay = plan.workouts.first?.day.lowercased() ?? ""
            let isMondayFirst = firstDay.hasPrefix("mon")
            let sIndex = max(0, min(6, weekday - 1))
            return isMondayFirst ? (weekday + 5) % 7 : sIndex
        }
        return min(appState.currentWorkoutDayIndex, max(0, plan.workouts.count - 1))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "0A0E27"), Color(hex: "1A1F3A")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ).ignoresSafeArea()
                
                VStack(spacing: 16) {
                    daySelector
                    Divider().background(Color.white.opacity(0.2))
                    workoutDetail
                }
                .padding(16)
            }
            .navigationTitle("Weekly Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.down")
                            .foregroundColor(.blue)
                    }
                }
            }
            .onAppear { selectedIndex = highlightIndex }
        }
    }
    
    private var daySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(plan.workouts.indices, id: \.self) { i in
                    let workout = plan.workouts[i]
                    Button(action: { selectedIndex = i }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(workout.day)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Text(workout.title)
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                                .lineLimit(1)
                        }
                        .padding(12)
                        .frame(minWidth: 160)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(i == highlightIndex ? Color.blue.opacity(0.25) : Color.white.opacity(0.06))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(i == selectedIndex ? Color.blue : Color.white.opacity(0.1), lineWidth: 2)
                        )
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    private var workoutDetail: some View {
        let workout = plan.workouts[selectedIndex]
        return ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("\(workout.day) • \(workout.title)")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                
                ForEach(workout.exercises) { ex in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(ex.name).font(.headline).foregroundColor(.white)
                            Spacer()
                            Text("Rest: \(formatRest(ex.restTime))")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        Text("\(ex.sets) sets • \(ex.reps)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.75))
                        if let url = ex.youtubeSearchURL {
                            Link(destination: url) {
                                Label("How to do it", systemImage: "play.rectangle.fill")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.06)))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
                }
            }
            .padding(.bottom, 20)
        }
    }
    
    private func formatRest(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return m > 0 ? "\(m)m \(s)s" : "\(s)s"
    }
}

