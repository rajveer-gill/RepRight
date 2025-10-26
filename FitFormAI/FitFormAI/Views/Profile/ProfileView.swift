import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSettings = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header with Avatar
                VStack(spacing: 16) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text(appState.userProfile?.name.prefix(1).uppercased() ?? "?")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        )
                    
                    Text(appState.userProfile?.name ?? "User")
                        .font(.title.bold())
                        .foregroundColor(.white)
                    
                    Text(appState.userProfile?.fitnessLevel.rawValue ?? "Fitness Enthusiast")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
                
                // Stats Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ProfileStatCard(title: "Workouts", value: "24", icon: "figure.walk")
                    ProfileStatCard(title: "Streak", value: "7 days", icon: "flame.fill")
                    ProfileStatCard(title: "Total Time", value: "540 min", icon: "clock.fill")
                    ProfileStatCard(title: "Form Checks", value: "12", icon: "video.fill")
                }
                .padding(.horizontal, 24)
                
                // Profile Info
                VStack(alignment: .leading, spacing: 16) {
                    Text("Profile Information")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                    
                    if let profile = appState.userProfile {
                        VStack(spacing: 12) {
                            ProfileInfoRow(label: "Age", value: "\(profile.age) years")
                            ProfileInfoRow(label: "Fitness Level", value: profile.fitnessLevel.rawValue)
                            ProfileInfoRow(label: "Primary Goals", value: profile.goals.map { $0.rawValue }.joined(separator: ", "))
                            ProfileInfoRow(label: "Workout Types", value: profile.preferredWorkoutTypes.map { $0.rawValue }.joined(separator: ", "))
                        }
                        .padding(.horizontal, 24)
                    }
                }
                
                // Settings Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Settings")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                    
                    VStack(spacing: 0) {
                        SettingsButton(icon: "person.fill", title: "Edit Profile", color: .blue) {}
                        Divider().background(Color.white.opacity(0.1))
                        
                        SettingsButton(icon: "bell.fill", title: "Notifications", color: .orange) {}
                        Divider().background(Color.white.opacity(0.1))
                        
                        SettingsButton(icon: "key.fill", title: "API Settings", color: .purple) {}
                        Divider().background(Color.white.opacity(0.1))
                        
                        SettingsButton(icon: "questionmark.circle.fill", title: "Help & Support", color: .green) {}
                        Divider().background(Color.white.opacity(0.1))
                        
                        SettingsButton(icon: "info.circle.fill", title: "About", color: .blue) {}
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.05))
                    )
                    .padding(.horizontal, 24)
                }
                
                // Delete All Data Button
                Button(action: deleteAllData) {
                    HStack {
                        Image(systemName: "trash.fill")
                        Text("Delete All Data")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.red.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 24)
                
                Spacer(minLength: 100)
            }
        }
    }
    
    private func deleteAllData() {
        // Clear all saved data and return to onboarding
        appState.hasCompletedOnboarding = false
        appState.userProfile = nil
        appState.currentWorkoutPlan = nil
        
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: "userProfile")
        UserDefaults.standard.removeObject(forKey: "currentWorkoutPlan")
    }
}

struct ProfileStatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
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
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct ProfileInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
                .textCase(.uppercase)
            
            Text(value)
                .font(.body)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct SettingsButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.3))
                    .font(.caption)
            }
            .padding()
        }
    }
}

