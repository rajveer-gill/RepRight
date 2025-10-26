import SwiftUI
import LocalAuthentication

struct LockedView: View {
    @EnvironmentObject var securityManager: SecurityManager
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "0A0E27"), Color(hex: "1A1F3A")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Image(systemName: securityManager.biometricType == .faceID ? "faceid" : securityManager.biometricType == .touchID ? "touchid" : "lock.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                VStack(spacing: 8) {
                    Text("App Locked")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Use \(biometricTypeText) to unlock")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Button(action: { securityManager.unlockApp() }) {
                    HStack {
                        Image(systemName: securityManager.biometricType == .faceID ? "faceid" : securityManager.biometricType == .touchID ? "touchid" : "key.fill")
                        Text("Unlock")
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
                .padding(.horizontal, 48)
            }
        }
    }
    
    private var biometricTypeText: String {
        switch securityManager.biometricType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .none:
            return "your passcode"
        }
    }
}

