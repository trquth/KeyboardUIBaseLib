
//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 23/8/25.
//

import Foundation

struct ProofReadDataResponse: Decodable {
    let output: String
    let promptUsed: String
    let version: String
    
    enum CodingKeys: String, CodingKey {
        case output = "output"
        case promptUsed = "prompt_used"
        case version = "version"
    }
}
