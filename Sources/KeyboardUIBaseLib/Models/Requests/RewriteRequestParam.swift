//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 23/8/25.
//

import Foundation

struct RewriteRequestParam: Codable, Sendable {
    let message: String
    let type: String
    let tone: String
    let persona: String
    let version: String
    
    init(message: String, tone: String, persona: String, type: String = "rewrite", version: String = "v1.0") {
        self.message = message
        self.tone = tone
        self.persona = persona
        self.type = type
        self.version = version
    }
}
