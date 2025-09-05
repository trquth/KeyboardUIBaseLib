//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 5/9/25.
//

import Foundation

// MARK: - ConversationDataResponse
struct ConversationDataResponse: Codable {
    let message: String
    let result: ConversationResult
}

// MARK: - Result
struct ConversationResult: Codable {
    let currentPosition, totalOutputs: Int
    let hasNext, hasPrevious, isFirst, isLast: Bool
}
