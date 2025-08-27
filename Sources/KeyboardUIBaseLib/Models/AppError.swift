import Foundation

public struct AppError: Error, Codable, LocalizedError {
    public let code: String
    public let field: String?
    public let message: String
    public let details: [String: String]?

    public init(code: String,field: String? = nil,  message: String, details: [String: String]? = nil) {
        self.code = code
        self.field = field
        self.message = message
        self.details = details
    }
    
    // MARK: - LocalizedError Conformance
    public var errorDescription: String? {
        return message
    }
    
    public var failureReason: String? {
        return details?["reason"]
    }
    
    // MARK: - Factory Methods
    
    public static func missingField(_ fieldName: String) -> AppError {
        return AppError(
            code: "MISSING_FIELD",
            field: fieldName,
            message: "\(fieldName.capitalized) is required",
            details: [
                "field": fieldName,
                "suggestion": "Please provide a value for \(fieldName)"
            ]
        )
    }
    
    public static func invalidField(_ fieldName: String, reason: String) -> AppError {
        return AppError(
            code: "INVALID_FIELD",
            field: fieldName,
            message: "\(fieldName.capitalized) is invalid: \(reason)",
            details: [
                "field": fieldName,
                "reason": reason,
                "suggestion": "Please provide a valid \(fieldName)"
            ]
        )
    }
    
    public static func custom(code: String, fieldName:String? = nil, message: String, suggestion: String? = nil) -> AppError {
        var details: [String: String] = [:]
        if let suggestion = suggestion {
            details["suggestion"] = suggestion
        }
        return AppError(code: code, field: fieldName, message: message, details: details)
    }
}
