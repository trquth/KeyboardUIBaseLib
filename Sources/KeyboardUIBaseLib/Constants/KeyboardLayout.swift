//
//  KeyboardLayout.swift
//  KeyboardBaseIOS
//
//  Created by Thien Tran-Quan on 18/8/25.
//

import Foundation

// MARK: - Keyboard Layout Configuration
struct KeyboardLayout {
    
    // MARK: - Layout Types
    enum LayoutType {
        case letters
        case numbers
        case symbols
    }
    
    // MARK: - Special Keys
    enum SpecialKey: String, CaseIterable {
        case shift = "⬆️"
        case delete = "⌫"
        case numbers = "?123"
        case symbols = "#+"
        case letters = "ABC"
        case globe = "🌐"
        case space = "space"
        case enter = "enter"
        case dot = "."
        case emoji = "😀"
        
        var displayText: String {
            switch self {
            case .space:
                return " "
            case .symbols:
                return "#+="
            default:
                return rawValue
            }
        }
        
        var isActionKey: Bool {
            switch self {
            case .shift, .delete, .numbers, .symbols, .letters, .globe, .enter, .dot, .emoji:
                return true
            case .space:
                return false
            }
        }
    }
    
    // MARK: - Letter Layout
    static let letterKeys: [[String]] = [
        // Top row
        ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
        
        // Middle row
        ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
        
        // Bottom row
        [SpecialKey.shift.rawValue, "z", "x", "c", "v", "b", "n", "m", SpecialKey.delete.rawValue],
        
        // Action row
        [SpecialKey.numbers.rawValue, SpecialKey.emoji.rawValue, SpecialKey.space.rawValue, SpecialKey.dot.rawValue, SpecialKey.enter.rawValue]
    ]
    
    // MARK: - Number Layout
    static let numberKeys: [[String]] = [
        // Top row
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
        
        // Middle row
        ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""],
        
        // Bottom row
        [SpecialKey.symbols.displayText, ".", ",", "?", "!", "'", SpecialKey.delete.rawValue],
        
        // Action row
        [SpecialKey.letters.rawValue, SpecialKey.emoji.rawValue, SpecialKey.space.rawValue, SpecialKey.enter.rawValue]
    ]
    
    // MARK: - Symbol Layout
    static let symbolKeys: [[String]] = [
        // Top row
        ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="],
        
        // Middle row
        ["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "·"],
        
        // Bottom row
        [SpecialKey.numbers.rawValue, ".", ",", "?", "!", "'", SpecialKey.delete.rawValue],
        
        // Action row
        [SpecialKey.letters.rawValue, SpecialKey.globe.rawValue, SpecialKey.space.rawValue, SpecialKey.enter.rawValue]
    ]
    
    // MARK: - Layout Getter
    static func getLayout(for type: LayoutType) -> [[String]] {
        switch type {
        case .letters:
            return letterKeys
        case .numbers:
            return numberKeys
        case .symbols:
            return symbolKeys
        }
    }
    
    // MARK: - Key Properties
    static func isSpecialKey(_ key: String) -> Bool {
        return SpecialKey.allCases.contains { $0.rawValue == key || $0.displayText == key }
    }
    
    static func getSpecialKey(for string: String) -> SpecialKey? {
        return SpecialKey.allCases.first { $0.rawValue == string || $0.displayText == string }
    }
    
    static func isActionKey(_ key: String) -> Bool {
        guard let specialKey = getSpecialKey(for: key) else { return false }
        return specialKey.isActionKey
    }
    
    // MARK: - Layout Dimensions
    static let rowCount = 4
    static let maxKeysInRow = 10
    
    // MARK: - Key Sizing
    struct KeySize {
        static let regular = CGSize(width: 30, height: 42)
        static let wide = CGSize(width: 187, height: 42)      // Space key
        static let action = CGSize(width: 40, height: 42)    // Shift, delete, etc.
        static let small = CGSize(width: 35, height: 42)     // Mode switches
    }
    
    static func getKeySize(for key: String, in row: Int) -> CGSize {
        guard let specialKey = getSpecialKey(for: key) else {
            return KeySize.regular
        }
        
        switch specialKey {
        case .space:
            return KeySize.wide
        case .shift, .delete:
            return KeySize.action
        case .numbers, .symbols, .letters, .globe, .enter, .dot,.emoji:
            return KeySize.small
        }
    }
}
