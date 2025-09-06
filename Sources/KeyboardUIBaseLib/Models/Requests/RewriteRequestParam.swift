//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 23/8/25.
//

import Foundation

public struct RewriteRequestParam: Codable, Sendable {
    let message: String
    let type: String
    let tone: String
    let persona: String
    let version: String
    let conversationId: String?
    
    init(message: String, tone: String, persona: String, type: String = "rewrite", version: String = "v1.0",
         conversationId: String? = nil) {
        self.message = message
        self.tone = tone
        self.persona = persona
        self.type = type
        self.version = version
        self.conversationId = conversationId
    }
}
