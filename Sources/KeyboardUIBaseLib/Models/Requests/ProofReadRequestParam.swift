//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 27/8/25.
//

import Foundation

public struct ProofreadRequestParam: Codable, Sendable {
    let message: String
    let type: String
    let version: String
    
    init(message: String, type: String = "proofread", version: String = "proofread-v1") {
        self.message = message
        self.type = type
        self.version = version
    }
}
