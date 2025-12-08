//
//  AuthenticationService.swift
//  Nomi
//
//  Created on December 7, 2025.
//

import Foundation
import AuthenticationServices
import Security

@MainActor
final class AuthenticationService: NSObject, ObservableObject {
    static let shared = AuthenticationService()
    
    private let keychainService = "com.nomi.auth"
    private let userIdKey = "apple_user_identifier"
    private let emailKey = "apple_user_email"
    
    private override init() {
        super.init()
    }
    
    // MARK: - Sign In with Apple
    
    func createSignInRequest() -> ASAuthorizationAppleIDRequest {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.email]
        return request
    }
    
    func handleAuthorization(result: Result<ASAuthorization, Error>) -> AuthResult {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                return .failure(.invalidCredential)
            }
            
            let userId = credential.user
            let email = credential.email
            
            // Save to keychain
            saveToKeychain(userId: userId, email: email)
            
            return .success(AuthData(userId: userId, email: email))
            
        case .failure(let error):
            if let authError = error as? ASAuthorizationError {
                switch authError.code {
                case .canceled:
                    return .failure(.canceled)
                case .failed:
                    return .failure(.failed)
                case .invalidResponse:
                    return .failure(.invalidResponse)
                case .notHandled:
                    return .failure(.notHandled)
                case .unknown:
                    return .failure(.unknown)
                case .notInteractive:
                    return .failure(.unknown)
                @unknown default:
                    return .failure(.unknown)
                }
            }
            return .failure(.unknown)
        }
    }
    
    // MARK: - Test/Debug Sign In
    
    #if DEBUG
    func signInAsTestUser() -> AuthResult {
        let testUserId = "test_user_\(UUID().uuidString.prefix(8))"
        let testEmail = "test@nomi.app"
        
        // Save test credentials to keychain
        saveToKeychain(userId: testUserId, email: testEmail)
        
        return .success(AuthData(userId: testUserId, email: testEmail))
    }
    #endif
    
    // MARK: - Session Management
    
    func getCurrentUserId() -> String? {
        return readFromKeychain(key: userIdKey)
    }
    
    func getCurrentEmail() -> String? {
        return readFromKeychain(key: emailKey)
    }
    
    func signOut() {
        deleteFromKeychain(key: userIdKey)
        deleteFromKeychain(key: emailKey)
    }
    
    func checkCredentialState() async -> ASAuthorizationAppleIDProvider.CredentialState? {
        guard let userId = getCurrentUserId() else { return nil }
        
        let provider = ASAuthorizationAppleIDProvider()
        
        do {
            let state = try await provider.credentialState(forUserID: userId)
            return state
        } catch {
            return nil
        }
    }
    
    // MARK: - Keychain Helpers
    
    private func saveToKeychain(userId: String, email: String?) {
        saveToKeychain(key: userIdKey, value: userId)
        if let email = email {
            saveToKeychain(key: emailKey, value: email)
        }
    }
    
    private func saveToKeychain(key: String, value: String) {
        let data = value.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func readFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    private func deleteFromKeychain(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Supporting Types

struct AuthData {
    let userId: String
    let email: String?
}

enum AuthResult {
    case success(AuthData)
    case failure(AuthError)
}

enum AuthError: Error, LocalizedError {
    case canceled
    case failed
    case invalidResponse
    case invalidCredential
    case notHandled
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .canceled:
            return "Sign in was canceled"
        case .failed:
            return "Sign in failed. Please try again."
        case .invalidResponse:
            return "Invalid response from Apple"
        case .invalidCredential:
            return "Invalid credential received"
        case .notHandled:
            return "Sign in request was not handled"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
