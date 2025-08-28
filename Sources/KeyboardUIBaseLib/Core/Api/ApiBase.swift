//
//  ApiBase.swift
//  SwiftUIBaseIOS
//
//  Created by Thien Tran-Quan on 30/5/25.
//
//https://github.dev/fatihdurmaz/GenericNetworkManagerSwiftUI
//https://github.com/Alamofire/Alamofire/blob/master/Documentation/Usage.md#using-alamofire

import Foundation
import Alamofire

struct HTTPHeaderBase {
    static let defaultHTTPHeader = HTTPHeaders([
        "Accept": "application/json",
        "Content-Type": "application/json"
    ])
    
    static func customHTTPHeader(_ header: [String: String]) -> HTTPHeaders {
        let defaultHeaders = defaultHTTPHeader.dictionary
        let customHeaders = defaultHeaders.merging(header) { (_, new) in new }
        return HTTPHeaders(customHeaders)
    }
    
    static func authHeader(token: String, type: String = "Bearer") -> HTTPHeaders {
        let authHeaders = [
            "Authorization": "\(type) \(token)"
        ]
        return customHTTPHeader(authHeaders)
    }
}

struct ApiBase: Sendable {
    static let shared = ApiBase()
    
    // Configuration
    private let session: Session
    private var defaultTimeout: TimeInterval { ApiConfiguration.shared.defaultTimeout }
    private var maxRetries: Int { ApiConfiguration.shared.maxRetries }
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = ApiConfiguration.shared.defaultTimeout
        configuration.timeoutIntervalForResource = ApiConfiguration.shared.defaultTimeout * 2
        configuration.waitsForConnectivity = true
        
        self.session = Session(configuration: configuration)
    }
    
    func request<T: Decodable>(
        url: String,
        method: HTTPMethodEnum = .get,
        parameters: [String: any Any & Sendable]? = nil,
        httpHeaders: [String: String]? = nil,
        encoding: any ParameterEncoding = URLEncoding.default,
        timeout: TimeInterval? = nil
    ) async throws -> BaseResponse<T> {
        
        guard URL(string: url) != nil else {
            throw ApiError.invalidURL
        }
        
        var headers = HTTPHeaderBase.defaultHTTPHeader
        if let httpHeaders = httpHeaders {
            headers = HTTPHeaderBase.customHTTPHeader(httpHeaders)
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = session.request(url, method: method.httpMethod, parameters: parameters, encoding: encoding, headers: headers)
            
            request
                .validate()
                .responseData { response in
                    // Log cURL command after request is prepared
                    if ApiConfiguration.shared.enableCurlLogging {
                        ApiBaseUtil.logCurlCommand(for: request)
                    }
                    
                    print("🌐 ApiBase: Received response for \(method.rawValue) request to: \(url) statusCode: \(response.response?.statusCode ?? 0)")
                    self.handleResponse(response: response, continuation: continuation)
                }
        }
    }
    
    func requestWithAuth<T: Decodable>(
        url: String,
        method: HTTPMethodEnum = .get,
        parameters: [String: any Any & Sendable]? = nil,
        encoding: ParameterEncoding = URLEncoding.default
    ) async throws -> BaseResponse<T> {
        
        // Get tokens from storage
        guard let token = TokenAppStorageService.shared.getAccessToken() else {
            throw ApiError.unauthorized
        }
        
        let tokenType = TokenAppStorageService.shared.getTokenType()
        
        // First attempt with current token
        let authHeaders = HTTPHeaderBase.authHeader(token: token, type: tokenType)
        
        do {
            return try await withCheckedThrowingContinuation { continuation in
                let request = session.request(url, method: method.httpMethod, parameters: parameters, encoding: encoding, headers: authHeaders)
                
                request
                    .validate()
                    .responseData { response in
                        // Log cURL command after request is prepared
                        if ApiConfiguration.shared.enableCurlLogging {
                            ApiBaseUtil.logCurlCommand(for: request)
                        }
                        
                        self.handleResponse(response: response, continuation: continuation)
                    }
            }
        } catch {
            // Check if refresh token handling is enabled and it's a 401 unauthorized error
            if let refreshToken = TokenAppStorageService.shared.getRefreshToken(),
               ApiConfiguration.shared.enableAutoRefresh,
               ApiConfiguration.shared.hasRefreshUrl(),
               let apiError = error as? ApiError,
               case .http(let statusCode, _) = apiError,
               statusCode == 401 {
                
                // Attempt to refresh token
                let newToken = try await refreshAccessToken(refreshToken: refreshToken)
                print("🔄 ApiBase: Token refreshed successfully \(newToken)")
                
                // Retry with new token (get updated token from storage after refresh)
                guard let updatedToken = TokenAppStorageService.shared.getAccessToken() else {
                    throw ApiError.unauthorized
                }
                
                let newAuthHeaders = HTTPHeaderBase.authHeader(token: updatedToken, type: "Bearer")
                
                return try await withCheckedThrowingContinuation { continuation in
                    let request = session.request(url, method: method.httpMethod, parameters: parameters, encoding: encoding, headers: newAuthHeaders)
                    
                    request
                        .validate()
                        .responseData { response in
                            // Log cURL command after request is prepared
                            if ApiConfiguration.shared.enableCurlLogging {
                                ApiBaseUtil.logCurlCommand(for: request)
                            }
                            
                            self.handleResponse(response: response, continuation: continuation)
                        }
                }
            }
            
            // Re-throw if not a 401 error or refresh not enabled
            throw error
        }
    }
    
    func refreshAccessToken(refreshToken: String? = nil) async throws -> String {
        let tokenToUse = refreshToken ?? TokenAppStorageService.shared.getRefreshToken()
        
        guard let finalRefreshToken = tokenToUse else {
            throw ApiError.unauthorized
        }
        
        guard ApiConfiguration.shared.hasRefreshUrl() else {
            throw ApiError.invalidURL
        }
        
        return try await TokenRefreshManager.shared.refreshAccessToken(
            refreshToken: finalRefreshToken,
            refreshUrl: ApiConfiguration.shared.refreshUrl
        )
    }
    
    // MARK: - Private Helper Methods
    
    private func handleResponse<T: Decodable>(
        response: AFDataResponse<Data>,
        continuation: CheckedContinuation<BaseResponse<T>, Error>
    ) {
        switch response.result {
        case .success(let data):
            do {
                let parsedData = try parseResponseData(T.self, from: data)
                let baseResponse = BaseResponse<T>(
                    status: response.response?.statusCode,
                    message: "Request completed successfully",
                    data: parsedData
                )
                print("✅ ApiBase: Request successful - Status: \(response.response?.statusCode ?? 0)")
                continuation.resume(returning: baseResponse)
            } catch {
                print("❌ ApiBase: Decoding error - \(error)")
                continuation.resume(throwing: ApiError.decoding(error))
            }
        case .failure:
            let apiError = handleAFError(response)
            print("❌ ApiBase: Request failed - \(apiError)")
            continuation.resume(throwing: apiError)
        }
    }
    
    private func parseResponseData<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        //decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }
    
    private func handleAFError(_ response: AFDataResponse<Data>) -> ApiError {
        if let statusCode = response.response?.statusCode {
            switch statusCode {
            case 400...499:
                return .http(statusCode: statusCode, data: response.data)
            case 500...599:
                return .http(statusCode: statusCode, data: response.data)
            default:
                return .http(statusCode: statusCode, data: response.data)
            }
        } else if let error = response.error {
            // Check for timeout errors
            if case .sessionTaskFailed(let sessionError) = error,
               let urlError = sessionError as? URLError,
               urlError.code == .timedOut {
                return .timeout
            }
            
            // Check for network connectivity errors
            if case .sessionTaskFailed(let sessionError) = error,
               let urlError = sessionError as? URLError,
               [.notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost].contains(urlError.code) {
                return .networkUnavailable
            }
            
            return .underlying(error)
        } else {
            return .unknown
        }
    }
}
