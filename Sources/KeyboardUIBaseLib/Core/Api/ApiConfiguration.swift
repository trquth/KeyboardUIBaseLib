//
//  ApiConfiguration.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 28/8/25.
//

import Foundation

/// Configuration service for API settings
public final class ApiConfiguration: @unchecked Sendable {
    public static let shared = ApiConfiguration()
    
    // MARK: - Thread Safety
    private let queue = DispatchQueue(label: "ApiConfiguration.queue", attributes: .concurrent)
    
    // MARK: - Configuration Properties
    
    private var _baseUrl: String = ""
    private var _refreshUrl: String = ""
    private var _defaultTimeout: TimeInterval = 30.0
    private var _maxRetries: Int = 3
    private var _enableAutoRefresh: Bool = true
    private var _enableCurlLogging: Bool = true
    
    /// Base URL for API requests
    public var baseUrl: String {
        get { queue.sync { _baseUrl } }
        set { queue.async(flags: .barrier) { self._baseUrl = newValue } }
    }
    
    /// Refresh token endpoint URL
    public var refreshUrl: String {
        get { queue.sync { _refreshUrl } }
        set { queue.async(flags: .barrier) { self._refreshUrl = newValue } }
    }
    
    /// Default timeout for requests
    public var defaultTimeout: TimeInterval {
        get { queue.sync { _defaultTimeout } }
        set { queue.async(flags: .barrier) { self._defaultTimeout = newValue } }
    }
    
    /// Maximum number of retries
    public var maxRetries: Int {
        get { queue.sync { _maxRetries } }
        set { queue.async(flags: .barrier) { self._maxRetries = newValue } }
    }
    
    /// Enable automatic token refresh
    public var enableAutoRefresh: Bool {
        get { queue.sync { _enableAutoRefresh } }
        set { queue.async(flags: .barrier) { self._enableAutoRefresh = newValue } }
    }
    
    /// Enable cURL logging for debugging
    public var enableCurlLogging: Bool {
        get { queue.sync { _enableCurlLogging } }
        set { queue.async(flags: .barrier) { self._enableCurlLogging = newValue } }
    }
    
    private init() {}
    
    // MARK: - Configuration Methods
    
    /// Configure API with basic settings
    /// - Parameters:
    ///   - baseUrl: Base URL for API requests
    ///   - refreshUrl: Refresh token endpoint URL
    public func configure(baseUrl: String, refreshUrl: String) {
        queue.async(flags: .barrier) {
            self._baseUrl = baseUrl
            self._refreshUrl = refreshUrl
        }
    }
    
    /// Configure API with all available settings
    /// - Parameters:
    ///   - baseUrl: Base URL for API requests
    ///   - refreshUrl: Refresh token endpoint URL
    ///   - timeout: Request timeout in seconds
    ///   - maxRetries: Maximum retry attempts
    ///   - enableAutoRefresh: Enable automatic token refresh
    ///   - enableCurlLogging: Enable cURL command logging
    public func configure(
        baseUrl: String,
        refreshUrl: String,
        timeout: TimeInterval = 30.0,
        maxRetries: Int = 3,
        enableAutoRefresh: Bool = true,
        enableCurlLogging: Bool = true
    ) {
        queue.async(flags: .barrier) {
            self._baseUrl = baseUrl
            self._refreshUrl = refreshUrl
            self._defaultTimeout = timeout
            self._maxRetries = maxRetries
            self._enableAutoRefresh = enableAutoRefresh
            self._enableCurlLogging = enableCurlLogging
        }
    }
    
    // MARK: - URL Building Helpers
    
    /// Build full URL from endpoint
    /// - Parameter endpoint: API endpoint (e.g., "/users", "/auth/login")
    /// - Returns: Full URL string
    public func fullUrl(for endpoint: String) -> String {
        return queue.sync {
            let cleanBase = _baseUrl.trimmingSuffix("/")
            let cleanEndpoint = endpoint.hasPrefix("/") ? endpoint : "/\(endpoint)"
            return cleanBase + cleanEndpoint
        }
    }
    
    /// Check if refresh URL is configured
    /// - Returns: True if refresh URL is set and not empty
    public func hasRefreshUrl() -> Bool {
        return queue.sync {
            return !_refreshUrl.isEmpty
        }
    }
}

// MARK: - String Extension

private extension String {
    func trimmingSuffix(_ suffix: String) -> String {
        if self.hasSuffix(suffix) {
            return String(self.dropLast(suffix.count))
        }
        return self
    }
}

// MARK: - Usage Examples
/*
 Example usage in your app initialization:

 ```swift
 // In AppDelegate or App.swift
 func configureAPI() {
     ApiConfiguration.shared.configure(
         baseUrl: "https://api.example.com",
         refreshUrl: "https://api.example.com/auth/refresh",
         timeout: 60.0,
         enableAutoRefresh: true,
         enableCurlLogging: true
     )
 }

 // Or simple configuration
 ApiConfiguration.shared.configure(
     baseUrl: "https://api.example.com",
     refreshUrl: "https://api.example.com/auth/refresh"
 )

 // Build URLs easily
 let loginUrl = ApiConfiguration.shared.fullUrl(for: "/auth/login")
 let userUrl = ApiConfiguration.shared.fullUrl(for: "users/profile")
 ```
 */
