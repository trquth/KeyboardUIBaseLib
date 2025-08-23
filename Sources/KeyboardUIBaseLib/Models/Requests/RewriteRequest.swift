//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 23/8/25.
//

import Foundation

struct RewriteRequest: Encodable {
    let message: String
    let type: String
    let tone: String
    let persona: String
    let version: String
}
