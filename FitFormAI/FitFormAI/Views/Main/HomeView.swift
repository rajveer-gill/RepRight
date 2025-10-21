import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    
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
                HStack(spacing: 12) {
                    StatCard(icon: "flame.fill", title: "Streak", value: "7 days", color: .orange)
                    StatCard(icon: "figure.walk", title: "Workouts", value: "24", color: .blue)
                    StatCard(icon: "clock.fill", title: "Minutes", value: "540", color: .green)
                }
                .padding(.horizontal, 24)
                
                // Today's Workout Card
                if let workout = appState.currentWorkoutPlan?.workouts.first {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Today's Workout")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                        
                        WorkoutCard(workout: workout)
                            .padding(.horizontal, 24)
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
                            gradient: [Color.blue, Color.purple]
                        )
                        
                        QuickActionButton(
                            icon: "video.fill",
                            title: "Check Your Form",
                            subtitle: "Upload or record video",
                            gradient: [Color.purple, Color.pink]
                        )
                        
                        QuickActionButton(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "View Progress",
                            subtitle: "Track your improvements",
                            gradient: [Color.green, Color.blue]
                        )
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer(minLength: 100)
            }
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.day)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                    
                    Text(workout.title)
                        .font(.title3.bold())
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
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
    
    var body: some View {
        Button(action: {}) {
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

