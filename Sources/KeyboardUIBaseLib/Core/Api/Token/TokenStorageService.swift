//
//  TokenStorageService.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 28/8/25.
//

import Foundation
import Security

/// Service for securely storing and retrieving authentication tokens
public final class TokenStorageService: @unchecked Sendable {
    public static let shared = TokenStorageService()
    
    // MARK: - Thread Safety
    private let queue = DispatchQueue(label: "TokenStorageService.queue", attributes: .concurrent)
    
    // MARK: - Keys
    private struct Keys {
        static let accessToken = "com.keyboarduibaselib.access_token"
        static let refreshToken = "com.keyboarduibaselib.refresh_token"
        static let tokenType = "com.keyboarduibaselib.token_type"
        static let expiresAt = "com.keyboarduibaselib.expires_at"
    }
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Save complete token information
    /// - Parameters:
    ///   - accessToken: The access token
    ///   - refreshToken: The refresh token (optional)
    ///   - tokenType: Token type (default: "Bearer")
    ///   - expiresIn: Token expiration time in seconds (optional)
    public func saveTokens(
        accessToken: String,
        refreshToken: String? = nil,
        tokenType: String = "Bearer",
        expiresIn: Int? = nil
    ) {
        queue.async(flags: .barrier) {
            // Save access token to keychain (more secure)
            self.saveToKeychain(key: Keys.accessToken, value: accessToken)
            
            // Save refresh token to keychain if provided
            if let refreshToken = refreshToken {
                self.saveToKeychain(key: Keys.refreshToken, value: refreshToken)
            }
            
            // Save token type to UserDefaults (less sensitive)
            UserDefaults.standard.set(tokenType, forKey: Keys.tokenType)
            
            // Calculate and save expiration date if provided
            if let expiresIn = expiresIn {
                let expirationDate = Date().addingTimeInterval(TimeInterval(expiresIn))
                UserDefaults.standard.set(expirationDate, forKey: Keys.expiresAt)
            }
            
            UserDefaults.standard.synchronize()
            print("✅ TokenStorageService: Tokens saved successfully")
        }
    }
    
    /// Save tokens from RefreshTokenResponse
    /// - Parameter response: The token response from API
    public func saveTokens(from response: TokenModel) {
        saveTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            tokenType: response.tokenType,
            expiresIn: response.expiresIn
        )
    }
    
    /// Get the current access token
    /// - Returns: Access token if available
    public func getAccessToken() -> String? {
        return queue.sync {
            return getFromKeychain(key: Keys.accessToken)
        }
    }
    
    /// Get the current refresh token
    /// - Returns: Refresh token if available
    public func getRefreshToken() -> String? {
        return queue.sync {
            return getFromKeychain(key: Keys.refreshToken)
        }
    }
    
    /// Get the token type
    /// - Returns: Token type (default: "Bearer")
    public func getTokenType() -> String {
        return queue.sync {
            return UserDefaults.standard.string(forKey: Keys.tokenType) ?? "Bearer"
        }
    }
    
    /// Get token expiration date
    /// - Returns: Expiration date if available
    public func getTokenExpirationDate() -> Date? {
        return queue.sync {
            return UserDefaults.standard.object(forKey: Keys.expiresAt) as? Date
        }
    }
    
    /// Check if access token is expired
    /// - Returns: True if token is expired or expiration date is unknown
    public func isAccessTokenExpired() -> Bool {
        guard let expirationDate = getTokenExpirationDate() else {
            return false // If no expiration date, assume not expired
        }
        return Date() >= expirationDate
    }
    
    /// Check if tokens are available
    /// - Returns: True if both access and refresh tokens are available
    public func hasValidTokens() -> Bool {
        return getAccessToken() != nil && getRefreshToken() != nil
    }
    
    /// Update only the access token (useful after refresh)
    /// - Parameters:
    ///   - accessToken: New access token
    ///   - expiresIn: Token expiration time in seconds (optional)
    public func updateAccessToken(_ accessToken: String, expiresIn: Int? = nil) {
        queue.async(flags: .barrier) {
            self.saveToKeychain(key: Keys.accessToken, value: accessToken)
            
            if let expiresIn = expiresIn {
                let expirationDate = Date().addingTimeInterval(TimeInterval(expiresIn))
                UserDefaults.standard.set(expirationDate, forKey: Keys.expiresAt)
            }
            
            UserDefaults.standard.synchronize()
            print("✅ TokenStorageService: Access token updated successfully")
        }
    }
    
    /// Clear all stored tokens
    public func clearTokens() {
        queue.async(flags: .barrier) {
            self.deleteFromKeychain(key: Keys.accessToken)
            self.deleteFromKeychain(key: Keys.refreshToken)
            UserDefaults.standard.removeObject(forKey: Keys.tokenType)
            UserDefaults.standard.removeObject(forKey: Keys.expiresAt)
            UserDefaults.standard.synchronize()
            print("✅ TokenStorageService: All tokens cleared")
        }
    }
    
    // MARK: - Private Keychain Methods
    
    private func saveToKeychain(key: String, value: String) {
        let data = Data(value.utf8)
        
        // Delete existing item first
        deleteFromKeychain(key: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "KeyboardUIBaseLib",
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            print("❌ TokenStorageService: Failed to save \(key) to keychain. Status: \(status)")
        }
    }
    
    private func getFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "KeyboardUIBaseLib",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            if let data = result as? Data {
                return String(data: data, encoding: .utf8)
            }
        } else if status != errSecItemNotFound {
            print("❌ TokenStorageService: Failed to retrieve \(key) from keychain. Status: \(status)")
        }
        
        return nil
    }
    
    private func deleteFromKeychain(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "KeyboardUIBaseLib"
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Convenience Extensions

public extension TokenStorageService {
    /// Get authorization header value
    /// - Returns: "Bearer {token}" or nil if no token
    func getAuthorizationHeader() -> String? {
        guard let accessToken = getAccessToken() else { return nil }
        return "\(getTokenType()) \(accessToken)"
    }
    
    /// Get tokens as a tuple
    /// - Returns: Tuple with access token and refresh token (both optional)
    func getTokenPair() -> (accessToken: String?, refreshToken: String?) {
        return (getAccessToken(), getRefreshToken())
    }
}

// MARK: - Usage Examples
/*
 Example usage in your app:

 ```swift
 // Save tokens after login
 TokenStorageService.shared.saveTokens(
     accessToken: "eyJhbGciOiJIUzI1NiIs...",
     refreshToken: "def50200a1b2c3d4e5f6...",
     tokenType: "Bearer",
     expiresIn: 3600
 )

 // Or save from API response
 let response: RefreshTokenResponse = // ... from API
 TokenStorageService.shared.saveTokens(from: response)

 // Get tokens for API calls
 if let accessToken = TokenStorageService.shared.getAccessToken(),
    let refreshToken = TokenStorageService.shared.getRefreshToken() {
     
     let apiResponse = try await ApiBase.shared.requestWithAuth(
         url: "https://api.example.com/data",
         method: .get,
         token: accessToken,
         refreshToken: refreshToken,
         refreshUrl: "https://api.example.com/auth/refresh"
     ) { newToken in
         // Update token when refreshed
         TokenStorageService.shared.updateAccessToken(newToken)
     }
 }

 // Check if tokens are valid
 if TokenStorageService.shared.hasValidTokens() && !TokenStorageService.shared.isAccessTokenExpired() {
     // Proceed with authenticated requests
 } else {
     // Show login screen
 }

 // Clear tokens on logout
 TokenStorageService.shared.clearTokens()
 ```
 */
