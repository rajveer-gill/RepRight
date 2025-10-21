import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)
                
                WorkoutPlanView()
                    .tag(1)
                
                FormCheckView()
                    .tag(2)
                
                ProfileView()
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .background(
            LinearGradient(
                colors: [Color(hex: "0A0E27"), Color(hex: "1A1F3A")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(icon: "house.fill", title: "Home", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            TabBarButton(icon: "figure.strengthtraining.traditional", title: "Workout", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            
            TabBarButton(icon: "video.fill", title: "Form Check", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
            
            TabBarButton(icon: "person.fill", title: "Profile", isSelected: selectedTab == 3) {
                selectedTab = 3
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(hex: "1A1F3A"))
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: -5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 30)
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(
                        isSelected ?
                        LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing) :
                        LinearGradient(colors: [.gray], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                isSelected ?
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue.opacity(0.2)) : nil
            )
        }
    }
}

