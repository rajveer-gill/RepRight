import Foundation
import LocalAuthentication
import SwiftUI

class SecurityManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLocked = false
    @Published var biometricType: BiometricType = .none
    
    enum BiometricType {
        case none
        case touchID
        case faceID
    }
    
    init() {
        checkBiometricType()
        loadAuthState()
    }
    
    func checkBiometricType() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .faceID:
                biometricType = .faceID
            case .touchID:
                biometricType = .touchID
            default:
                biometricType = .none
            }
        } else {
            biometricType = .none
        }
    }
    
    func authenticate(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            // Fallback to passcode
            authenticateWithPasscode(completion: completion)
            return
        }
        
        let reason = "Access your secure workout data"
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
            DispatchQueue.main.async {
                if success {
                    self.isAuthenticated = true
                    self.saveAuthState()
                    completion(true)
                } else {
                    self.isAuthenticated = false
                    completion(false)
                }
            }
        }
    }
    
    private func authenticateWithPasscode(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        let reason = "Enter your passcode to access RepRight"
        
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
            DispatchQueue.main.async {
                if success {
                    self.isAuthenticated = true
                    self.saveAuthState()
                    completion(true)
                } else {
                    self.isAuthenticated = false
                    completion(false)
                }
            }
        }
    }
    
    func lockApp() {
        isLocked = true
        isAuthenticated = false
        saveAuthState()
    }
    
    func unlockApp() {
        authenticate { success in
            if success {
                self.isLocked = false
            }
        }
    }
    
    private func saveAuthState() {
        UserDefaults.standard.set(isAuthenticated, forKey: "isAuthenticated")
        UserDefaults.standard.set(isLocked, forKey: "isLocked")
    }
    
    private func loadAuthState() {
        isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
        isLocked = UserDefaults.standard.bool(forKey: "isLocked")
    }
    
    func resetAuth() {
        isAuthenticated = false
        isLocked = false
        UserDefaults.standard.removeObject(forKey: "isAuthenticated")
        UserDefaults.standard.removeObject(forKey: "isLocked")
    }
}

