import SwiftUI

struct WorkoutFlowView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var appState: AppState
    @State private var workflowStep: WorkflowStep = .ready
    @State private var selectedExercise: Exercise? = nil
    @State private var completedExercises: Set<UUID> = []
    @State private var ongoingWorkoutStartTime: Date? = nil
    @State private var currentWorkoutId: UUID? = nil
    
    private var todayWorkout: Workout? {
        appState.getCurrentWorkout()
    }
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    var allExercisesCompleted: Bool {
        guard let workout = todayWorkout else { return false }
        return completedExercises.count >= workout.exercises.count
    }
    
    enum WorkflowStep {
        case ready
        case workoutSelection
        case active
        case completed
    }
    
    var body: some View {
        Group {
            switch workflowStep {
            case .ready:
                ReadyToWorkoutView(
                    onReady: {
                        // Mark that user has attempted the workout
                        appState.attemptWorkout()
                        workflowStep = .workoutSelection
                    },
                    onCancel: { isPresented = false }
                )
            case .workoutSelection:
                if allExercisesCompleted {
                    WorkoutCompleteView(
                        onGoHome: { isPresented = false },
                        streakCount: appState.streakCount
                    )
                } else {
                    ExerciseSelectionView(
                        onExerciseSelected: { exercise in
                            selectedExercise = exercise
                            workflowStep = .active
                            if ongoingWorkoutStartTime == nil {
                                ongoingWorkoutStartTime = Date()
                                appState.workoutStartTime = ongoingWorkoutStartTime
                            }
                        },
                        onCancel: { isPresented = false },
                        completedExercises: completedExercises,
                        exerciseSetProgress: appState.exerciseSetProgress,
                        workoutStartTime: ongoingWorkoutStartTime
                    )
                }
            case .active:
                if let exercise = selectedExercise {
                    ActiveExerciseView(
                        exercise: exercise,
                        currentSetNumber: appState.exerciseSetProgress[exercise.id] ?? 1,
                        workoutStartTime: ongoingWorkoutStartTime ?? Date(),
                        onComplete: { completedSets, minutes in
                            // Save minutes if ending early
                            if minutes > 0 {
                                appState.workoutMinutesToday = minutes
                                appState.saveWorkoutMinutes()
                            }
                            
                            if completedSets >= exercise.sets {
                                // All sets done - mark exercise as complete
                                completedExercises.insert(exercise.id)
                                appState.exerciseSetProgress[exercise.id] = exercise.sets
                                appState.saveExerciseProgress()
                                
                                // Check if all exercises are done
                                if allExercisesCompleted {
                                    appState.completeWorkout()
                                    workflowStep = .completed
                                } else {
                                    workflowStep = .workoutSelection
                                }
                            } else {
                                // Save progress and return to selection
                                appState.exerciseSetProgress[exercise.id] = completedSets
                                appState.saveExerciseProgress()
                                workflowStep = .workoutSelection
                            }
                        }
                    )
                }
            case .completed:
                WorkoutCompleteView(
                    onGoHome: { isPresented = false },
                    streakCount: appState.streakCount
                )
            }
        }
        .onAppear {
            // Set initial workout ID
            currentWorkoutId = todayWorkout?.id
            // Load workout start time if it exists (for continuity)
            if let startTime = appState.workoutStartTime {
                ongoingWorkoutStartTime = startTime
            }
        }
        .onChange(of: appState.currentWorkoutDayIndex) { newIndex in
            // Only reset when the workflow is already in a finished state
            // Don't interrupt if we're showing the completion screen
            if workflowStep != .completed {
                currentWorkoutId = todayWorkout?.id
                completedExercises.removeAll()
                appState.exerciseSetProgress.removeAll()
                appState.saveExerciseProgress()
                workflowStep = .ready
            }
        }
    }
}

// MARK: - Ready to Workout View

struct ReadyToWorkoutView: View {
    let onReady: () -> Void
    let onCancel: () -> Void
    @State private var currentMessage = MotivationalMessages.readyToWorkout.randomElement() ?? "Are you ready?"
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "0A0E27"), Color(hex: "1A1F3A")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                Text(currentMessage)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                HStack(spacing: 30) {
                    Button(action: onCancel) {
                        Text("Not Yet")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 140, height: 50)
                            .background(Color.gray.opacity(0.6))
                            .cornerRadius(16)
                    }
                    
                    Button(action: onReady) {
                        Text("Let's Go!")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 140, height: 50)
                            .background(
                                LinearGradient(
                                    colors: [.green, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                    }
                }
                .padding(.bottom, 60)
            }
        }
    }
}

// MARK: - Exercise Selection View

struct ExerciseSelectionView: View {
    @EnvironmentObject var appState: AppState
    let onExerciseSelected: (Exercise) -> Void
    let onCancel: () -> Void
    var completedExercises: Set<UUID>
    var exerciseSetProgress: [UUID: Int]
    var workoutStartTime: Date?
    @State private var selectedExerciseId: UUID? = nil
    
    private var todayWorkout: Workout? {
        appState.getCurrentWorkout()
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "0A0E27"), Color(hex: "1A1F3A")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Top bar with end workout button
                HStack {
                    Button(action: {
                        // Reset minutes when exiting workout early
                        appState.workoutMinutesToday = 0
                        appState.saveWorkoutMinutes()
                        onCancel()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.red.opacity(0.3))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    if let startTime = workoutStartTime {
                        VStack(spacing: 4) {
                            Text("Workout Time")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            Text(formatWorkoutTime(startTime))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Text("Choose Your Exercise")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                if let workout = todayWorkout {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Debug: Show current day index
                            Text("Day \(appState.currentWorkoutDayIndex + 1) - \(workout.day)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.bottom, 8)
                            
                            ForEach(Array(workout.exercises.enumerated()), id: \.element.id) { index, exercise in
                                Button(action: {
                                    // Don't allow starting completed exercises
                                    if completedExercises.contains(exercise.id) {
                                        return
                                    }
                                    
                                    if selectedExerciseId == exercise.id {
                                        // Tapped twice - start exercise
                                        onExerciseSelected(exercise)
                                    } else {
                                        // First tap - highlight
                                        selectedExerciseId = exercise.id
                                    }
                                }) {
                                    ExerciseSelectionCard(
                                        exercise: exercise,
                                        isRecommended: index == 0,
                                        isSelected: selectedExerciseId == exercise.id,
                                        isCompleted: completedExercises.contains(exercise.id),
                                        currentSetProgress: exerciseSetProgress[exercise.id] ?? 0
                                    )
                                }
                                .disabled(completedExercises.contains(exercise.id))
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
            }
        }
    }
    
    func formatWorkoutTime(_ startTime: Date) -> String {
        let elapsed = Date().timeIntervalSince(startTime)
        let minutes = Int(elapsed) / 60
        let seconds = Int(elapsed) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Exercise Selection Card

struct ExerciseSelectionCard: View {
    let exercise: Exercise
    let isRecommended: Bool
    let isSelected: Bool
    let isCompleted: Bool
    let currentSetProgress: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                if isCompleted && !isSelected {
                    Text("COMPLETED")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                } else if isRecommended && !isSelected && !isCompleted {
                    Text("RECOMMENDED START")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                
                if isSelected {
                    Text("TAP TO START")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                Text(exercise.name)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .strikethrough(isCompleted && !isSelected)
                
                HStack(spacing: 16) {
                    if currentSetProgress > 0 && !isCompleted {
                        Label("\(currentSetProgress)/\(exercise.sets) sets", systemImage: "repeat")
                            .font(.caption)
                            .foregroundColor(.orange)
                    } else {
                        Label("\(exercise.sets) sets", systemImage: "repeat")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Label(exercise.reps, systemImage: "number")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Spacer()
            
            Image(systemName: isCompleted ? "checkmark.circle.fill" : (isSelected ? "checkmark.circle.fill" : "chevron.right"))
                .foregroundColor(isCompleted || isSelected ? .green : .white.opacity(0.5))
                .font(.system(size: 24))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? Color.green.opacity(0.2) : (isCompleted ? Color.gray.opacity(0.1) : Color.white.opacity(0.05)))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.green : (isCompleted ? Color.gray : (isRecommended ? Color.orange : Color.white.opacity(0.1))), lineWidth: 2)
                )
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Active Exercise View

struct ActiveExerciseView: View {
    let exercise: Exercise
    let currentSetNumber: Int
    let workoutStartTime: Date
    let onComplete: (Int, Int) -> Void // Returns (completedSets, minutes)
    
    @State private var currentState: WorkoutActiveState = .set
    @State private var setStartTime = Date()
    @State private var pulsatingScale: CGFloat = 1.0
    @State private var backgroundColors: [Color] = [.red, .orange]
    @State private var currentMessage = MotivationalMessages.duringWorkout.randomElement() ?? "YOU GOT THIS!"
    @State private var showEndWorkoutConfirmation = false
    @State private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var currentTime = Date()
    @State private var restTimeElapsed: TimeInterval = 0
    @State private var setNumber: Int
    @State private var completedSetsCount: Int = 0
    
    init(exercise: Exercise, currentSetNumber: Int, workoutStartTime: Date, onComplete: @escaping (Int, Int) -> Void) {
        self.exercise = exercise
        self.currentSetNumber = currentSetNumber
        self.workoutStartTime = workoutStartTime
        self.onComplete = onComplete
        self._setNumber = State(initialValue: currentSetNumber)
        // Set completed sets count (subtract 1 because setNumber is the NEXT set to do)
        self._completedSetsCount = State(initialValue: max(0, currentSetNumber - 1))
    }
    
    enum WorkoutActiveState {
        case set
        case rest
    }
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .onAppear {
                startPulsatingAnimation()
            }
            
            VStack(spacing: 30) {
                // Timer and control buttons
                HStack {
                    // End workout button
                    Button(action: {
                        showEndWorkoutConfirmation = true
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.red.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .padding(.leading)
                    
                    Spacer()
                    
                            // Total workout time
                            VStack(spacing: 4) {
                                Text("Total Time")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                Text(formatTime(elapsed: Date().timeIntervalSince(workoutStartTime)))
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                            }
                }
                .padding(.top, 20)
                
                if currentState == .set {
                    setTimeDisplay
                } else {
                    restTimeDisplay
                }
                
                // Motivational message
                Text(currentMessage)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .scaleEffect(pulsatingScale)
                
                Spacer()
                
                // Action button
                if currentState == .set {
                    Button(action: completeSet) {
                        Text("SET DONE")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.9))
                            .cornerRadius(20)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                } else {
                    Button(action: startNextSet) {
                        Text("START NEXT SET")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.9))
                            .cornerRadius(20)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
            }
        }
        .alert("End Workout?", isPresented: $showEndWorkoutConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("End Workout", role: .destructive) {
                let minutes = Int(Date().timeIntervalSince(workoutStartTime) / 60)
                onComplete(completedSetsCount, minutes)
            }
        } message: {
            Text("Are you sure you want to end your workout?")
        }
        .onAppear {
            setStartTime = Date()
        }
        .onReceive(timer) { _ in
            currentTime = Date()
            
            // Check if we're in rest mode and update background/message
            if currentState == .rest {
                restTimeElapsed = currentTime.timeIntervalSince(setStartTime)
                let remainingTime = TimeInterval(exercise.restTime) - restTimeElapsed
                
                // 10 seconds or less remaining - change to green and update message
                if remainingTime <= 10 && remainingTime > 0 && backgroundColors[0] != Color(red: 0.0, green: 0.5, blue: 0.0) {
                    backgroundColors = [Color(red: 0.0, green: 0.5, blue: 0.0), Color(red: 0.0, green: 0.7, blue: 0.2)]
                    currentMessage = MotivationalMessages.timeToStart.randomElement() ?? "Time to start!"
                }
            }
        }
    }
    
    var setTimeDisplay: some View {
        VStack(spacing: 8) {
            Text("Current Set Time")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            Text(formatTime(elapsed: currentTime.timeIntervalSince(setStartTime)))
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)
            
            Text("Set \(setNumber)/\(exercise.sets) - \(exercise.name)")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
                .padding(.top, 8)
        }
    }
    
    var restTimeDisplay: some View {
        VStack(spacing: 8) {
            Text("Rest Time")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            Text(formatTime(elapsed: currentTime.timeIntervalSince(setStartTime)))
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)
            
            Text("Target: \(formatRestTime(exercise.restTime))")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .padding(.top, 8)
        }
    }
    
    func startPulsatingAnimation() {
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            pulsatingScale = 1.1
        }
    }
    
    func completeSet() {
        completedSetsCount += 1
        setNumber += 1
        
        // Check if all sets are done for this exercise
        if setNumber > exercise.sets {
            // All sets complete - call onComplete with the number of completed sets and 0 minutes (not ending workout)
            onComplete(completedSetsCount, 0)
            return
        }
        
        let restMessage = MotivationalMessages.restPeriod.randomElement() ?? "Take a rest!"
        currentMessage = restMessage
        backgroundColors = [.blue, .purple]
        currentState = .rest
        setStartTime = Date()
        restTimeElapsed = 0 // Reset elapsed time for new rest period
    }
    
    func startNextSet() {
        let workoutMessage = MotivationalMessages.duringWorkout.randomElement() ?? "YOU GOT THIS!"
        currentMessage = workoutMessage
        backgroundColors = [.red, .orange]
        currentState = .set
        setStartTime = Date()
    }
    
    func formatTime(elapsed: TimeInterval) -> String {
        let minutes = Int(elapsed) / 60
        let seconds = Int(elapsed) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func formatRestTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        if mins > 0 {
            return "\(mins)m \(secs)s"
        }
        return "\(secs)s"
    }
}

// MARK: - Workout Complete View

struct WorkoutCompleteView: View {
    let onGoHome: () -> Void
    let streakCount: Int
    @State private var celebrationScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: [.green, .blue, .purple, .pink],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .onAppear {
                startCelebrationAnimation()
            }
            
            VStack(spacing: 40) {
                Spacer()
                
                // Celebration Icon
                Image(systemName: "trophy.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(celebrationScale)
                    .rotationEffect(.degrees(celebrationScale == 1.0 ? 0 : 360))
                
                // Main Message
                VStack(spacing: 16) {
                    Text("WORKOUT COMPLETE!")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("You crushed it today! 💪")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                    
                    Text("Streak: \(streakCount) days 🔥")
                        .font(.title2.bold())
                        .foregroundColor(.yellow)
                }
                
                // Reminders Card
                VStack(alignment: .leading, spacing: 16) {
                    Text("Stay Consistent! 🔥")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    HStack(spacing: 12) {
                        Image(systemName: "fork.knife")
                            .foregroundColor(.green)
                        Text("Get your protein in!")
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    HStack(spacing: 12) {
                        Image(systemName: "bed.double.fill")
                            .foregroundColor(.blue)
                        Text("Rest and recover tonight")
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    HStack(spacing: 12) {
                        Image(systemName: "moon.fill")
                            .foregroundColor(.purple)
                        Text("Tomorrow: Day \(streakCount + 1)!")
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                )
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Go Home Button
                Button(action: onGoHome) {
                    Text("Back to Home")
                        .font(.title3.bold())
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
                        .cornerRadius(20)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
    }
    
    func startCelebrationAnimation() {
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            celebrationScale = 1.2
        }
    }
}

