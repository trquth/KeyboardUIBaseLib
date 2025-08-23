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
        print("🌐 HTTPHeaderBase: Custom HTTP Headers created - \(customHeaders)")
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
    private let defaultTimeout: TimeInterval = 30.0
    private let maxRetries: Int = 3
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = defaultTimeout
        configuration.timeoutIntervalForResource = defaultTimeout * 2
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
        
        print("🌐 ApiBase: Making \(method.rawValue) request to: \(url) with headers: \(headers) and parameters: \(parameters ?? [:])")
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(url, method: method.httpMethod, parameters: parameters, encoding: encoding, headers: headers)
                .validate()
                .responseData { response in
                    print("🌐 ApiBase: Received response for \(method.rawValue) request to: \(url) statusCode: \(response.response?.statusCode ?? 0)")
                    self.handleResponse(response: response, continuation: continuation)
                }
        }
    }
    
    func requestWithAuth<T: Decodable>(
        url: String,
        method: HTTPMethodEnum = .get,
        parameters: [String: any Any & Sendable]? = nil,
        token: String,
        tokenType: String = "Bearer",
        encoding: ParameterEncoding = URLEncoding.default
    ) async throws -> BaseResponse<T> {
        
        let authHeaders = HTTPHeaderBase.authHeader(token: token, type: tokenType)
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(url, method: method.httpMethod, parameters: parameters, encoding: encoding, headers: authHeaders)
                .validate()
                .responseData { response in
                    self.handleResponse(response: response, continuation: continuation)
                }
        }
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
