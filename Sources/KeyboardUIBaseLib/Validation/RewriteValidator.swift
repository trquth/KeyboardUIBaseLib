//
//  RewriteValidator.swift
//  KeyboardUIBaseLib
//
//  Created by GitHub Copilot on 27/8/25.
//

import Foundation

public struct RewriteValidator {
    
    // MARK: - Validation Constants
    private static let maxMessageLength = 10000000
    private static let minMessageLength = 1
    
    // MARK: - Main Validation Method
    
    /// Validates a complete RewriteRequestParam
    /// - Parameter data: The rewrite request data to validate
    /// - Throws: AppError if validation fails
    public static func validate(_ data: RewriteRequestParam) throws {
        try validateMessage(data.message)
        try validateTone(data.tone)
        try validatePersona(data.persona)
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
    
    /// Validates the tone field
    /// - Parameter tone: The tone to validate
    /// - Throws: AppError if validation fails
    public static func validateTone(_ tone: String) throws {
        let trimmedTone = tone.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTone.isEmpty else {
            throw AppError.missingField("tone")
        }
    }
    
    /// Validates the persona field
    /// - Parameter persona: The persona to validate
    /// - Throws: AppError if validation fails
    public static func validatePersona(_ persona: String) throws {
        let trimmedPersona = persona.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedPersona.isEmpty else {
            throw AppError.missingField("persona")
        }
    }
    
    // MARK: - Utility Methods
    
    
    /// Creates a pre-validated RewriteRequestParam
    /// - Parameters:
    ///   - message: The message to rewrite
    ///   - tone: The tone to use
    ///   - persona: The persona to use
    /// - Returns: Validated RewriteRequestParam
    /// - Throws: AppError if validation fails
    public static func createValidatedRequest(
        message: String,
        tone: String,
        persona: String
    ) throws -> RewriteRequestParam {
        let request = RewriteRequestParam(
            message: message,
            tone: tone,
            persona: persona
        )
        
        try validate(request)
        return request
    }
}
