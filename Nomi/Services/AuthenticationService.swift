import Foundation
import AuthenticationServices

// MARK: - Authentication Service

@MainActor
class AuthenticationService: NSObject, ObservableObject {
    
    static let shared = AuthenticationService()
    
    @Published var isAuthenticated = false
    @Published var currentUserID: String?
    @Published var currentUserEmail: String?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let userDefaults = UserDefaults.standard
    private let appleUserIDKey = "appleUserID"
    private let userEmailKey = "userEmail"
    
    private override init() {
        super.init()
        checkExistingCredentials()
    }
    
    // MARK: - Public Methods
    
    func signInWithApple() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
        
        isLoading = true
    }
    
    func signOut() {
        userDefaults.removeObject(forKey: appleUserIDKey)
        userDefaults.removeObject(forKey: userEmailKey)
        
        currentUserID = nil
        currentUserEmail = nil
        isAuthenticated = false
    }
    
    // MARK: - Private Methods
    
    private func checkExistingCredentials() {
        guard let userID = userDefaults.string(forKey: appleUserIDKey) else {
            return
        }
        
        // Verify the credential is still valid
        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID) { [weak self] state, error in
            DispatchQueue.main.async {
                switch state {
                case .authorized:
                    self?.currentUserID = userID
                    self?.currentUserEmail = self?.userDefaults.string(forKey: self!.userEmailKey)
                    self?.isAuthenticated = true
                case .revoked, .notFound:
                    self?.signOut()
                default:
                    break
                }
            }
        }
    }
    
    private func handleSuccessfulSignIn(userID: String, email: String?) {
        userDefaults.set(userID, forKey: appleUserIDKey)
        if let email = email {
            userDefaults.set(email, forKey: userEmailKey)
        }
        
        currentUserID = userID
        currentUserEmail = email
        isAuthenticated = true
        isLoading = false
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AuthenticationService: ASAuthorizationControllerDelegate {
    
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }
        
        let userID = credential.user
        let email = credential.email
        
        Task { @MainActor in
            handleSuccessfulSignIn(userID: userID, email: email)
        }
    }
    
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Task { @MainActor in
            self.error = error
            self.isLoading = false
        }
    }
}
