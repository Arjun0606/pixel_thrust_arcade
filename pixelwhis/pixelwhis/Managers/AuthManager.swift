import Foundation
import AuthenticationServices
import Combine

@Observable
class AuthManager {
    var isAuthenticated = false
    var currentUser: AuthenticatedUser?
    var username: String?
    
    private let usernameKey = "pixelthrust_username"
    private let userIDKey = "pixelthrust_userID"
    
    init() {
        loadUserSession()
    }
    
    // MARK: - Apple Sign-In
    func signInWithApple(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userID = appleIDCredential.user
                
                // Save user ID
                UserDefaults.standard.set(userID, forKey: userIDKey)
                
                // Check if username exists
                if let savedUsername = UserDefaults.standard.string(forKey: usernameKey) {
                    // User has username, complete sign-in
                    completeSignIn(userID: userID, username: savedUsername)
                } else {
                    // First time - need username
                    currentUser = AuthenticatedUser(
                        id: userID,
                        username: nil,
                        email: appleIDCredential.email
                    )
                    isAuthenticated = true
                }
            }
            
        case .failure(let error):
            print("❌ Sign-in failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Username Management
    func setUsername(_ username: String) {
        guard let user = currentUser else { return }
        
        // Validate username
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 3, trimmed.count <= 15 else {
            print("❌ Username must be 3-15 characters")
            return
        }
        
        // Save username
        UserDefaults.standard.set(trimmed, forKey: usernameKey)
        self.username = trimmed
        
        // Update user
        currentUser = AuthenticatedUser(
            id: user.id,
            username: trimmed,
            email: user.email
        )
        
        print("✅ Username set: \(trimmed)")
    }
    
    // MARK: - Session Management
    private func loadUserSession() {
        guard let userID = UserDefaults.standard.string(forKey: userIDKey),
              let savedUsername = UserDefaults.standard.string(forKey: usernameKey) else {
            return
        }
        
        completeSignIn(userID: userID, username: savedUsername)
    }
    
    private func completeSignIn(userID: String, username: String) {
        currentUser = AuthenticatedUser(
            id: userID,
            username: username,
            email: nil
        )
        self.username = username
        isAuthenticated = true
        
        print("✅ Signed in as: \(username)")
    }
    
    func signOut() {
        UserDefaults.standard.removeObject(forKey: userIDKey)
        UserDefaults.standard.removeObject(forKey: usernameKey)
        
        currentUser = nil
        username = nil
        isAuthenticated = false
        
        print("👋 Signed out")
    }
}

// MARK: - User Model
struct AuthenticatedUser: Identifiable {
    let id: String
    var username: String?
    let email: String?
}
