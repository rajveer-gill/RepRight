import SwiftUI

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
            // Sunday-based index
            let sIndex = max(0, min(6, weekday - 1))
            if isMondayFirst {
                // Convert to Monday-based
                return (weekday + 5) % 7
            }
            return sIndex
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


