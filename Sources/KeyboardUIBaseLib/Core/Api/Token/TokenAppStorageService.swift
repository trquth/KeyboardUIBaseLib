//
//  TokenAppStorageService.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 28/8/25.
//

import Foundation

/// Service for storing and retrieving authentication tokens using UserDefaults
/// Note: This is less secure than TokenStorageService (which uses Keychain)
/// Use this for development, testing, or when security is not a primary concern
public final class TokenAppStorageService: @unchecked Sendable {
    public static let shared = TokenAppStorageService()
    
    // MARK: - Thread Safety
    private let queue = DispatchQueue(label: "TokenAppStorageService.queue", attributes: .concurrent)
    
    // MARK: - Keys
    private struct Keys {
        static let accessToken = "com.keyboarduibaselib.userdefaults.access_token"
        static let refreshToken = "com.keyboarduibaselib.userdefaults.refresh_token"
        static let tokenType = "com.keyboarduibaselib.userdefaults.token_type"
        static let expiresAt = "com.keyboarduibaselib.userdefaults.expires_at"
    }
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Save complete token information to UserDefaults
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
            let userDefaults = UserDefaults.standard
            
            // Save access token
            userDefaults.set(accessToken, forKey: Keys.accessToken)
            
            // Save refresh token if provided
            if let refreshToken = refreshToken {
                userDefaults.set(refreshToken, forKey: Keys.refreshToken)
            }
            
            // Save token type
            userDefaults.set(tokenType, forKey: Keys.tokenType)
            
            // Calculate and save expiration date if provided
            if let expiresIn = expiresIn {
                let expirationDate = Date().addingTimeInterval(TimeInterval(expiresIn))
                userDefaults.set(expirationDate, forKey: Keys.expiresAt)
            }
            
            userDefaults.synchronize()
            print("✅ TokenAppStorageService: Tokens saved successfully to UserDefaults")
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
            return UserDefaults.standard.string(forKey: Keys.accessToken)
        }
    }
    
    /// Get the current refresh token
    /// - Returns: Refresh token if available
    public func getRefreshToken() -> String? {
        return queue.sync {
            return UserDefaults.standard.string(forKey: Keys.refreshToken)
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
            let userDefaults = UserDefaults.standard
            
            userDefaults.set(accessToken, forKey: Keys.accessToken)
            
            if let expiresIn = expiresIn {
                let expirationDate = Date().addingTimeInterval(TimeInterval(expiresIn))
                userDefaults.set(expirationDate, forKey: Keys.expiresAt)
            }
            
            userDefaults.synchronize()
            print("✅ TokenAppStorageService: Access token updated successfully")
        }
    }
    
    /// Clear all stored tokens
    public func clearTokens() {
        queue.async(flags: .barrier) {
            let userDefaults = UserDefaults.standard
            
            userDefaults.removeObject(forKey: Keys.accessToken)
            userDefaults.removeObject(forKey: Keys.refreshToken)
            userDefaults.removeObject(forKey: Keys.tokenType)
            userDefaults.removeObject(forKey: Keys.expiresAt)
            
            userDefaults.synchronize()
            print("✅ TokenAppStorageService: All tokens cleared from UserDefaults")
        }
    }
    
    /// Get all token data as a dictionary (useful for debugging)
    /// - Returns: Dictionary containing all stored token information
    public func getAllTokenData() -> [String: Any] {
        return queue.sync {
            let userDefaults = UserDefaults.standard
            var tokenData: [String: Any] = [:]
            
            if let accessToken = userDefaults.string(forKey: Keys.accessToken) {
                tokenData["accessToken"] = accessToken
            }
            if let refreshToken = userDefaults.string(forKey: Keys.refreshToken) {
                tokenData["refreshToken"] = refreshToken
            }
            if let tokenType = userDefaults.string(forKey: Keys.tokenType) {
                tokenData["tokenType"] = tokenType
            }
            if let expiresAt = userDefaults.object(forKey: Keys.expiresAt) as? Date {
                tokenData["expiresAt"] = expiresAt
                tokenData["isExpired"] = Date() >= expiresAt
            }
            
            return tokenData
        }
    }
    
    /// Migrate tokens from Keychain-based TokenStorageService
    /// - Parameter keychainService: The TokenStorageService instance to migrate from
    public func migrateFromKeychain(_ keychainService: TokenStorageService) {
        queue.async(flags: .barrier) {
            // Get tokens from keychain service
            let accessToken = keychainService.getAccessToken()
            let refreshToken = keychainService.getRefreshToken()
            let tokenType = keychainService.getTokenType()
            let expirationDate = keychainService.getTokenExpirationDate()
            
            // Save to UserDefaults if tokens exist
            if let accessToken = accessToken {
                let userDefaults = UserDefaults.standard
                
                userDefaults.set(accessToken, forKey: Keys.accessToken)
                userDefaults.set(tokenType, forKey: Keys.tokenType)
                
                if let refreshToken = refreshToken {
                    userDefaults.set(refreshToken, forKey: Keys.refreshToken)
                }
                
                if let expirationDate = expirationDate {
                    userDefaults.set(expirationDate, forKey: Keys.expiresAt)
                }
                
                userDefaults.synchronize()
                print("✅ TokenAppStorageService: Successfully migrated tokens from Keychain to UserDefaults")
            } else {
                print("⚠️ TokenAppStorageService: No tokens found in Keychain to migrate")
            }
        }
    }
}

// MARK: - Convenience Extensions

public extension TokenAppStorageService {
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
    
    /// Check if tokens exist and are not expired
    /// - Returns: True if valid, non-expired tokens exist
    func hasValidNonExpiredTokens() -> Bool {
        return hasValidTokens() && !isAccessTokenExpired()
    }
}

// MARK: - Usage Examples
/*
 Example usage in your app:

 ```swift
 // Save tokens after login
 TokenAppStorageService.shared.saveTokens(
     accessToken: "eyJhbGciOiJIUzI1NiIs...",
     refreshToken: "def50200a1b2c3d4e5f6...",
     tokenType: "Bearer",
     expiresIn: 3600
 )

 // Or save from API response
 let response: RefreshTokenResponse = // ... from API
 TokenAppStorageService.shared.saveTokens(from: response)

 // Get tokens for API calls
 if let accessToken = TokenAppStorageService.shared.getAccessToken(),
    let refreshToken = TokenAppStorageService.shared.getRefreshToken() {
     
     // Use tokens for API requests
     print("Access Token: \(accessToken)")
     print("Refresh Token: \(refreshToken)")
 }

 // Check if tokens are valid and not expired
 if TokenAppStorageService.shared.hasValidNonExpiredTokens() {
     // Proceed with authenticated requests
     print("✅ Valid tokens available")
 } else {
     // Show login screen
     print("❌ Need to login")
 }

 // Debug: Print all token data
 let tokenData = TokenAppStorageService.shared.getAllTokenData()
 print("Token Data: \(tokenData)")

 // Migrate from Keychain to UserDefaults
 TokenAppStorageService.shared.migrateFromKeychain(TokenStorageService.shared)

 // Clear tokens on logout
 TokenAppStorageService.shared.clearTokens()
 ```

 // MARK: - SwiftUI Integration
 
 ```swift
 @AppStorage("com.keyboarduibaselib.userdefaults.access_token") 
 private var accessToken: String = ""
 
 // Or use the service directly in ViewModels
 @StateObject private var tokenService = TokenAppStorageService.shared
 ```
 
 // MARK: - Security Considerations
 
 ⚠️ **Important Security Notes:**
 - UserDefaults is NOT encrypted and can be accessed by other apps in some scenarios
 - Use TokenStorageService (Keychain) for production apps with sensitive data
 - TokenAppStorageService is suitable for:
   - Development and testing
   - Non-sensitive tokens
   - Shared app groups
   - Quick prototyping
 */
