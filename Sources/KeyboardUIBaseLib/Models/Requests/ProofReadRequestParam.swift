//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 27/8/25.
//

import Foundation

public struct ProofreadRequestParam: Codable, Sendable {
    let message, type,version: String
    let conversationId: String?
    
    init(message: String, type: String = "proofread", version: String = "proofread-v1", conversationId: String? = nil) {
        self.message = message
        self.type = type
        self.version = version
        self.conversationId = conversationId
    }
}
