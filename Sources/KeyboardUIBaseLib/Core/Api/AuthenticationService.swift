////
////  AuthenticationService.swift
////  KeyboardUIBaseLib
////
////  Created by Thien Tran-Quan on 28/8/25.
////
//
//import Foundation
//import Alamofire
//
///// Comprehensive authentication service that combines token storage and API requests
//@MainActor
//public class AuthenticationService: ObservableObject {
//    public static let shared = AuthenticationService()
//    
//    // MARK: - Published Properties
//    @Published public private(set) var isAuthenticated: Bool = false
//    @Published public private(set) var isLoading: Bool = false
//    
//    private let tokenStorage = TokenStorageService.shared
//    private let apiBase = ApiBase.shared
//    
//    private init() {
//        checkAuthenticationStatus()
//    }
//    
//    // MARK: - Authentication Status
//    
//    /// Check current authentication status
//    public func checkAuthenticationStatus() {
//        isAuthenticated = tokenStorage.hasValidTokens() && !tokenStorage.isAccessTokenExpired()
//    }
//    
//    /// Get current access token
//    public func getCurrentAccessToken() -> String? {
//        return tokenStorage.getAccessToken()
//    }
//    
//    /// Get current refresh token
//    public func getCurrentRefreshToken() -> String? {
//        return tokenStorage.getRefreshToken()
//    }
//    
//    // MARK: - Login & Logout
//    
//    /// Perform login and store tokens
//    /// - Parameters:
//    ///   - url: Login endpoint URL
//    ///   - parameters: Login parameters (username, password, etc.)
//    ///   - encoding: Parameter encoding (default: JSON)
//    /// - Returns: Login response data
//    public func login<T: Decodable>(
//        url: String,
//        parameters: [String: any Any & Sendable],
//        encoding: ParameterEncoding = JSONEncoding.default
//    ) async throws -> T {
//        isLoading = true
//        defer { isLoading = false }
//        
//        let response: BaseResponse<T> = try await apiBase.request(
//            url: url,
//            method: .post,
//            parameters: parameters,
//            encoding: encoding
//        )
//        
//        // If response contains token information, try to extract and save it
//        if let data = response.data, let tokenResponse = data as? RefreshTokenResponse {
//            tokenStorage.saveTokens(from: tokenResponse)
//            checkAuthenticationStatus()
//        }
//        
//        guard let data = response.data else {
//            throw ApiError.noData
//        }
//        
//        return data
//    }
//    
//    /// Perform logout and clear tokens
//    /// - Parameter logoutUrl: Optional logout endpoint URL
//    public func logout(logoutUrl: String? = nil) async {
//        isLoading = true
//        defer { 
//            isLoading = false
//            checkAuthenticationStatus()
//        }
//        
//        // Call logout endpoint if provided
//        if let logoutUrl = logoutUrl,
//           let accessToken = tokenStorage.getAccessToken() {
//            do {
//                let _: BaseResponse<EmptyResponse> = try await apiBase.requestWithAuth(
//                    url: logoutUrl,
//                    method: .post,
//                    token: accessToken
//                )
//                print("✅ AuthenticationService: Logout API call successful")
//            } catch {
//                print("⚠️ AuthenticationService: Logout API call failed - \(error)")
//                // Continue with local logout even if API call fails
//            }
//        }
//        
//        // Clear stored tokens
//        tokenStorage.clearTokens()
//    }
//    
//    // MARK: - Authenticated API Requests
//    
//    /// Make authenticated API request with automatic token refresh
//    /// - Parameters:
//    ///   - url: Request URL
//    ///   - method: HTTP method
//    ///   - parameters: Request parameters
//    ///   - encoding: Parameter encoding
//    /// - Returns: API response
//    public func authenticatedRequest<T: Decodable>(
//        url: String,
//        method: HTTPMethodEnum = .get,
//        parameters: [String: any Any & Sendable]? = nil,
//        encoding: ParameterEncoding = URLEncoding.default
//    ) async throws -> BaseResponse<T> {
//        guard let accessToken = tokenStorage.getAccessToken() else {
//            throw ApiError.unauthorized
//        }
//        
//        let refreshToken = tokenStorage.getRefreshToken()
//        let tokenType = tokenStorage.getTokenType()
//        
//        return try await apiBase.requestWithAuth(
//            url: url,
//            method: method,
//            parameters: parameters,
//            encoding: encoding
//        ) { [weak self] newToken in
//            // Token was refreshed, update authentication status
//            await MainActor.run {
//                self?.checkAuthenticationStatus()
//            }
//        }
//    }
//    
//    // MARK: - Manual Token Management
//    
//    /// Manually save tokens (useful for custom login flows)
//    /// - Parameters:
//    ///   - accessToken: Access token
//    ///   - refreshToken: Refresh token
//    ///   - tokenType: Token type (default: "Bearer")
//    ///   - expiresIn: Expiration time in seconds
//    public func saveTokens(
//        accessToken: String,
//        refreshToken: String? = nil,
//        tokenType: String = "Bearer",
//        expiresIn: Int? = nil
//    ) {
//        tokenStorage.saveTokens(
//            accessToken: accessToken,
//            refreshToken: refreshToken,
//            tokenType: tokenType,
//            expiresIn: expiresIn
//        )
//        checkAuthenticationStatus()
//    }
//    
//    /// Manually refresh access token
//    /// - Returns: New access token
//    public func refreshAccessToken() async throws -> String {
//        guard let refreshToken = tokenStorage.getRefreshToken() else {
//            throw ApiError.unauthorized
//        }
//        
//        guard ApiConfiguration.shared.hasRefreshUrl() else {
//            throw ApiError.invalidURL
//        }
//        
//        isLoading = true
//        defer { 
//            isLoading = false
//            checkAuthenticationStatus()
//        }
//        
//        let newToken = try await TokenRefreshManager.shared.refreshAccessToken(
//            refreshToken: refreshToken,
//            refreshUrl: ApiConfiguration.shared.refreshUrl
//        )
//        
//        return newToken
//    }
//}
//
//// MARK: - Supporting Types
//
///// Empty response for logout and other endpoints that don't return data
//public struct EmptyResponse: Codable, Sendable {
//    public init() {}
//}
//
//// MARK: - Usage Examples
///*
// Example usage in your app:
//
// ```swift
// @StateObject private var authService = AuthenticationService.shared
//
// // Configure API settings first
// override func viewDidLoad() {
//     super.viewDidLoad()
//     ApiConfiguration.shared.configure(
//         baseUrl: "https://api.example.com",
//         refreshUrl: "https://api.example.com/auth/refresh"
//     )
// }
//
// // Login
// func performLogin() async {
//     do {
//         let response: LoginResponse = try await authService.login(
//             url: "https://api.example.com/auth/login",
//             parameters: [
//                 "email": email,
//                 "password": password
//             ]
//         )
//         // Login successful, authService.isAuthenticated will be updated automatically
//     } catch {
//         // Handle login error
//     }
// }
//
// // Make authenticated requests (no need to pass refresh URL)
// func loadUserData() async {
//     do {
//         let response: BaseResponse<UserData> = try await authService.authenticatedRequest(
//             url: "https://api.example.com/user",
//             method: .get
//         )
//         // Handle user data
//     } catch {
//         // Handle error (will automatically handle token refresh if needed)
//     }
// }
//
// // Logout
// func performLogout() async {
//     await authService.logout(logoutUrl: "https://api.example.com/auth/logout")
//     // authService.isAuthenticated will be updated automatically
// }
//
// // Monitor authentication status in SwiftUI
// var body: some View {
//     Group {
//         if authService.isAuthenticated {
//             MainAppView()
//         } else {
//             LoginView()
//         }
//     }
//     .onChange(of: authService.isAuthenticated) { isAuth in
//         // React to authentication changes
//     }
// }
// ```
// */
