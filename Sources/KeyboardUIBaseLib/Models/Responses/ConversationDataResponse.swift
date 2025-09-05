//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 5/9/25.
//

import Foundation

//// MARK: - ConversationDataResponse
//struct ConversationDataResponse: Codable {
//    let message: String
//    let result: ConversationResult
//}
//
//// MARK: - Result
//struct ConversationResult: Codable {
//    let currentPosition, totalOutputs: Int
//    let hasNext, hasPrevious, isFirst, isLast: Bool
//}

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
    let conversation: ConversationData
}

// MARK: - Conversation
struct ConversationData: Codable {
    let output, promptUsed, version, conversationID: String
    let outputID: String

    enum CodingKeys: String, CodingKey {
        case output
        case promptUsed = "prompt_used"
        case version
        case conversationID = "conversationId"
        case outputID = "outputId"
    }
}
