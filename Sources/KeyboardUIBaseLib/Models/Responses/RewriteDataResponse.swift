//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 23/8/25.
//

import Foundation

//struct RewriteDataResponse: Decodable {
//    let output: String
//    let promptUsed: String
//    let version: String
//    let conversationId: String
//    let outputId: String
//    
//    enum CodingKeys: String, CodingKey {
//        case output = "output"
//        case promptUsed = "prompt_used"
//        case version = "version"
//        case conversationId = "conversationId"
//        case outputId = "outputId"
//    }
//}

// MARK: - RewriteDataReponse
struct RewriteDataResponse: Codable {
    let currentPosition, totalOutputs: Int
    let hasNext, hasPrevious, isFirst, isLast: Bool
    let conversation: Conversation
}

// MARK: - Conversation
struct Conversation: Codable {
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
