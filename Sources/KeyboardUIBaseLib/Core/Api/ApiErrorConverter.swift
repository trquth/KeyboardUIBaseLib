//
//  ApiErrorConverter.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 27/8/25.
//

import Foundation

/// Converts ApiError to AppError for consistent error handling throughout the app
public struct ApiErrorConverter {
    
    /// Converts an ApiError to AppError with user-friendly messages and suggestions
    /// - Parameter apiError: The ApiError to convert
    /// - Returns: An AppError with appropriate code, message, and suggestions
    public static func convert(_ apiError: ApiError) -> AppError {
        switch apiError {
        case .http(let statusCode, let data):
            return handleHTTPError(statusCode: statusCode, data: data)
            
        case .decoding(let error):
            return AppError.custom(
                code: "DECODING_ERROR",
                message: "Failed to parse server response",
                suggestion: "The server response format is unexpected. Please try again or contact support."
            )
            
        case .underlying(let error):
            return AppError.custom(
                code: "NETWORK_ERROR",
                message: "Network request failed: \(error.localizedDescription)",
                suggestion: "Please check your internet connection and try again."
            )
            
        case .invalidURL:
            return AppError.custom(
                code: "INVALID_URL",
                message: "The request URL is invalid",
                suggestion: "Please contact support if this issue persists."
            )
            
        case .noData:
            return AppError.custom(
                code: "NO_DATA",
                message: "No data received from server",
                suggestion: "Please try again. If the problem persists, contact support."
            )
            
        case .timeout:
            return AppError.custom(
                code: "REQUEST_TIMEOUT",
                message: "Request timed out",
                suggestion: "Please check your internet connection and try again."
            )
            
        case .networkUnavailable:
            return AppError.custom(
                code: "NETWORK_UNAVAILABLE",
                message: "Network is not available",
                suggestion: "Please check your internet connection and try again."
            )
            
        case .unknown:
            return AppError.custom(
                code: "UNKNOWN_ERROR",
                message: "An unexpected error occurred",
                suggestion: "Please try again. If the problem persists, contact support."
            )
        }
    }
    
    /// Handles HTTP errors with specific status code handling and server response parsing
    /// - Parameters:
    ///   - statusCode: HTTP status code
    ///   - data: Response data from server (may contain error details)
    /// - Returns: AppError with parsed server message or default message
    private static func handleHTTPError(statusCode: Int, data: Data?) -> AppError {
        // Try to parse server error response
        if let data = data,
           let errorResponse = try? JSONDecoder().decode([String: String].self, from: data) {
            let message = errorResponse["message"] ?? errorResponse["error"] ?? "HTTP Error \(statusCode)"
            let code = errorResponse["code"] ?? "HTTP_\(statusCode)"
            
            return AppError.custom(
                code: code,
                message: message,
                suggestion: getHTTPErrorSuggestion(for: statusCode)
            )
        }
        
        // Try to parse as ErrorResponse structure if available
        if let data = data,
           let errorResponse = try? JSONDecoder().decode(ServerErrorResponse.self, from: data) {
            return AppError.custom(
                code: errorResponse.code ?? "HTTP_\(statusCode)",
                message: errorResponse.message,
                suggestion: getHTTPErrorSuggestion(for: statusCode)
            )
        }
        
        // Fallback to default HTTP error messages based on status code
        return getDefaultHTTPError(for: statusCode)
    }
    
    /// Returns default AppError for common HTTP status codes
    /// - Parameter statusCode: HTTP status code
    /// - Returns: Default AppError for the status code
    private static func getDefaultHTTPError(for statusCode: Int) -> AppError {
        switch statusCode {
        case 400:
            return AppError.custom(
                code: "BAD_REQUEST",
                message: "Invalid request",
                suggestion: "Please check your input and try again."
            )
            
        case 401:
            return AppError.custom(
                code: "UNAUTHORIZED",
                message: "Authentication failed",
                suggestion: "Please log in again."
            )
            
        case 403:
            return AppError.custom(
                code: "FORBIDDEN",
                message: "Access denied",
                suggestion: "You don't have permission to perform this action."
            )
            
        case 404:
            return AppError.custom(
                code: "NOT_FOUND",
                message: "Resource not found",
                suggestion: "The requested resource could not be found."
            )
            
        case 409:
            return AppError.custom(
                code: "CONFLICT",
                message: "Request conflicts with current state",
                suggestion: "Please refresh and try again."
            )
            
        case 422:
            return AppError.custom(
                code: "VALIDATION_ERROR",
                message: "Invalid input data",
                suggestion: "Please check your input and try again."
            )
            
        case 429:
            return AppError.custom(
                code: "RATE_LIMITED",
                message: "Too many requests",
                suggestion: "Please wait a moment before trying again."
            )
            
        case 500:
            return AppError.custom(
                code: "INTERNAL_SERVER_ERROR",
                message: "Internal server error",
                suggestion: "Please try again later. If the problem persists, contact support."
            )
            
        case 502:
            return AppError.custom(
                code: "BAD_GATEWAY",
                message: "Server is temporarily unavailable",
                suggestion: "Please try again later."
            )
            
        case 503:
            return AppError.custom(
                code: "SERVICE_UNAVAILABLE",
                message: "Service is temporarily unavailable",
                suggestion: "Please try again later."
            )
            
        case 504:
            return AppError.custom(
                code: "GATEWAY_TIMEOUT",
                message: "Server response timeout",
                suggestion: "Please try again later."
            )
            
        case 500...599:
            return AppError.custom(
                code: "SERVER_ERROR",
                message: "Server error occurred",
                suggestion: "Please try again later. If the problem persists, contact support."
            )
            
        default:
            return AppError.custom(
                code: "HTTP_ERROR",
                message: "HTTP Error \(statusCode)",
                suggestion: "An unexpected error occurred. Please try again."
            )
        }
    }
    
    /// Returns appropriate suggestion text based on HTTP status code category
    /// - Parameter statusCode: HTTP status code
    /// - Returns: User-friendly suggestion string
    private static func getHTTPErrorSuggestion(for statusCode: Int) -> String {
        switch statusCode {
        case 400...499:
            return "Please check your input and try again."
        case 500...599:
            return "Server is experiencing issues. Please try again later."
        default:
            return "Please try again. If the problem persists, contact support."
        }
    }
}

/// Helper structure for parsing server error responses
private struct ServerErrorResponse: Codable {
    let code: String?
    let message: String
    let field: String?
    let details: [String: String]?
}

// MARK: - Convenience Extensions

extension ApiError {
    /// Converts this ApiError to AppError using ApiErrorConverter
    /// - Returns: AppError with user-friendly message and suggestions
    public func toAppError() -> AppError {
        return ApiErrorConverter.convert(self)
    }
}

// MARK: - Usage Examples

/*
 Usage Examples:

 1. Direct conversion:
 ```swift
 do {
     let response = try await ApiBase.shared.request(...)
 } catch {
     if let apiError = error as? ApiError {
         let appError = ApiErrorConverter.convert(apiError)
         // Handle appError with user-friendly messages
     }
 }
 ```

 2. Using extension:
 ```swift
 do {
     let response = try await ApiBase.shared.request(...)
 } catch {
     if let apiError = error as? ApiError {
         let appError = apiError.toAppError()
         // Handle appError
     }
 }
 ```

 3. In ViewModels:
 ```swift
 @MainActor
 class SomeViewModel: ObservableObject {
     @Published var error: AppError?
     
     func performAPICall() async {
         do {
             let response = try await ApiBase.shared.request(...)
         } catch {
             if let apiError = error as? ApiError {
                 self.error = apiError.toAppError()
             }
         }
     }
 }
 ```
 */
