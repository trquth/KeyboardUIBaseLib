//
//  RewriteValidator.swift
//  KeyboardUIBaseLib
//
//  Created by GitHub Copilot on 27/8/25.
//

import Foundation

public struct ProofreadValidator {
    
    // MARK: - Validation Constants
    private static let maxMessageLength = 10000000
    private static let minMessageLength = 1
    
    // MARK: - Main Validation Method
    
    /// Validates a complete ProofreadRequestParam
    /// - Parameter data: The rewrite request data to validate
    /// - Throws: AppError if validation fails
    public static func validate(_ data: ProofreadRequestParam) throws {
        try validateMessage(data.message)
    }
    
    // MARK: - Individual Field Validation
    
    /// Validates the message field
    /// - Parameter message: The message to validate
    /// - Throws: AppError if validation fails
    public static func validateMessage(_ message: String) throws {
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedMessage.isEmpty else {
            throw AppError.invalidField("message", reason: "cannot be empty")
        }
        
        guard trimmedMessage.count >= minMessageLength else {
            throw AppError.invalidField("message", reason: "too short")
        }
        
        guard trimmedMessage.count <= maxMessageLength else {
            throw AppError.invalidField("message", reason: "exceeds maximum length of \(maxMessageLength) characters")
        }
    }
    
    // MARK: - Utility Methods
    
    
    /// Creates a pre-validated ProofreadRequestParam
    /// - Parameters:
    ///   - message: The message to rewrite
    ///   - tone: The tone to use
    ///   - persona: The persona to use
    /// - Returns: Validated ProofreadRequestParam
    /// - Throws: AppError if validation fails
    public static func createValidatedRequest(
        message: String
    ) throws -> ProofreadRequestParam {
        let request = ProofreadRequestParam(
            message: message
        )

        try validate(request)
        return request
    }
}
