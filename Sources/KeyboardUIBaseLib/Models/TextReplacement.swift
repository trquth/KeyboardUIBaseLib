//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 21/8/25.
//

import Foundation

// MARK: - Text Replacement Model
public struct TextReplacement: Identifiable {
    public let id = UUID()
    public let shortcut: String
    public let replacement: String
    
    public init(shortcut: String, replacement: String) {
        self.shortcut = shortcut
        self.replacement = replacement
    }
}
