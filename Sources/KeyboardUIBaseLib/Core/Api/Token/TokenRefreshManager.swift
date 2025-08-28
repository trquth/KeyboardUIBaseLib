//
//  TokenRefreshManager.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 28/8/25.
//

import Foundation
import Alamofire

/// Manages token refresh operations with thread safety
@MainActor
public class TokenRefreshManager {
    public static let shared = TokenRefreshManager()
    
    private var isRefreshing: Bool = false
    private var refreshCompletions: [CheckedContinuation<String, Error>] = []
    
    private init() {}
    
    /// Handles token refresh with concurrent request management
    /// - Parameters:
    ///   - refreshToken: The refresh token to use
    ///   - refreshUrl: The URL endpoint for token refresh
    /// - Returns: New access token
    public func refreshAccessToken(refreshToken: String, refreshUrl: String) async throws -> String {
        // If already refreshing, wait for the current refresh to complete
        if isRefreshing {
            return try await waitForRefreshCompletion()
        }
        
        isRefreshing = true
        defer { isRefreshing = false }
        
        do {
            let refreshParameters: [String: any Any & Sendable] = [
                "refreshToken": refreshToken,
            ]
            
            let response: BaseResponse<RefreshTokenResponse?> = try await ApiBase.shared.request(
                url: refreshUrl,
                method: .post,
                parameters: refreshParameters,
                encoding: JSONEncoding.default
            )
            
            guard let tokenData = response.data else {
                throw ApiError.noData
            }
            
            let newAccessToken = tokenData.data.accessToken
            let token = TokenModel(
                accessToken: newAccessToken,
                refreshToken: refreshToken
            )
            // Automatically update stored tokens
            TokenAppStorageService.shared.saveTokens(from: token)
            
            // Notify all waiting requests
            notifyRefreshCompletion(result: .success(newAccessToken))
            
            print("✅ TokenRefreshManager: Token refreshed successfully")
            return newAccessToken
            
        } catch {
            // Notify all waiting requests of failure
            notifyRefreshCompletion(result: .failure(error))
            print("❌ TokenRefreshManager: Token refresh failed - \(error)")
            throw error
        }
    }
    
    /// Waits for an ongoing refresh operation to complete
    private func waitForRefreshCompletion() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            refreshCompletions.append(continuation)
        }
    }
    
    /// Notifies all waiting refresh operations
    private func notifyRefreshCompletion(result: Result<String, Error>) {
        for continuation in refreshCompletions {
            continuation.resume(with: result)
        }
        refreshCompletions.removeAll()
    }
}

// MARK: - Usage Examples
/*
 Example usage in your ViewModels or Services:

 ```swift
 @MainActor
 class YourViewModel: ObservableObject {
     private let tokenManager = TokenRefreshManager.shared
     
     func makeAuthenticatedRequest() async {
         do {
             let response = try await ApiBase.shared.requestWithAutoRefresh(
                 url: "https://api.example.com/data",
                 method: .get,
                 token: currentAccessToken,
                 refreshToken: currentRefreshToken,
                 refreshUrl: "https://api.example.com/auth/refresh"
             ) { newToken in
                 // Update stored token
                 self.currentAccessToken = newToken
                 UserDefaults.standard.set(newToken, forKey: "access_token")
             }
             // Handle successful response
         } catch {
             // Handle error
         }
     }
 }
 ```
 */
