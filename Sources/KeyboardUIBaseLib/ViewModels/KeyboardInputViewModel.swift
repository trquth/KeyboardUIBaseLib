//
//  KeyboardInputViewModel.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 22/8/25.
//

import Foundation
import SwiftUI

typealias TextChangeCallback = (KeyItem) -> Void

public class KeyboardInputViewModel: ObservableObject {
    @Published public var inputText: String = ""
    @Published public var lastPressedKey: String = ""
    @Published public var currentKeyboard: KeyboardType = .text
    @Published public var currentTypingInput: String = ""
    @Published public var lastWordTyped: String = ""
    
    public init() {
    }
    
    public init(inputText: String) {
        self.inputText = inputText
    }
    
    public init(lastWordTyped: String) {
        self.lastWordTyped = lastWordTyped
    }
    
    func setInputText(_ text: String) {
        inputText = text
        updateLastWordTyped()
    }
    
    func clearInputText() {
        if !inputText.isEmpty {
            inputText = ""
            lastWordTyped = ""
        }
    }
    
    public func resetCurrentTypingInput() {
        if !currentTypingInput.isEmpty {
            currentTypingInput = ""
        }
    }
    
    public func resetLastWordTyped() {
        if !lastWordTyped.isEmpty {
            lastWordTyped = ""
        }}
    
    // MARK: - Last Word Extraction
    private func updateLastWordTyped() {
        lastWordTyped = getLastWordFromInput()
    }
    
    private func getLastWordFromInput() -> String {
        // Remove trailing spaces and get the last word
        let trimmedInput = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If input is empty, return empty string
        guard !trimmedInput.isEmpty else {
            return ""
        }
        
        // Split by whitespace and get the last component
        let words = trimmedInput.components(separatedBy: .whitespacesAndNewlines)
        return words.last ?? ""
    }
    
    // Public method to manually get the current last word
    public func getCurrentLastWord() -> String {
        return getLastWordFromInput()
    }
    
    // MARK: - Text Replacement Methods
    public func replaceLastWordWith(_ replacement: String) {
        guard !inputText.isEmpty else {
            // If input is empty, just add the replacement
            inputText = replacement
            updateLastWordTyped()
            return
        }
        
        let trimmedInput = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        let words = trimmedInput.components(separatedBy: .whitespacesAndNewlines)
        
        if words.count > 1 {
            // Replace the last word while keeping the previous words and spaces
            var newWords = Array(words.dropLast())
            newWords.append(replacement)
            inputText = newWords.joined(separator: " ")
        } else {
            // Only one word, replace it entirely
            inputText = replacement
        }
        
        // Preserve trailing spaces if they existed
        if inputText != trimmedInput && inputText.last != " " {
            inputText += " "
        }
        
        updateLastWordTyped()
        print("🔄 Replaced last word with: '\(replacement)' -> Current input: '\(inputText)', Last word: '\(lastWordTyped)'")
    }
    
//    public func replaceLastWordWith(_ replacement: String, callback: TextChangeCallback?) {
//        replaceLastWordWith(replacement)
//        callback?(KeyItem(value: replacement, key: nil))
//    }
    
    // Replace word at specific index (0-based)
    public func replaceWordAt(index: Int, with replacement: String) {
        guard !inputText.isEmpty else { return }
        
        let trimmedInput = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        var words = trimmedInput.components(separatedBy: .whitespacesAndNewlines)
        
        guard index >= 0 && index < words.count else {
            return
        }
        
        words[index] = replacement
        inputText = words.joined(separator: " ")
        
        // Preserve trailing spaces if they existed
        if inputText != trimmedInput && !inputText.hasSuffix(" ") {
            inputText += " "
        }
        
        updateLastWordTyped()
    }
    
    // Get word at specific index
    public func getWordAt(index: Int) -> String? {
        guard !inputText.isEmpty else { return nil }
        
        let trimmedInput = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        let words = trimmedInput.components(separatedBy: .whitespacesAndNewlines)
        
        guard index >= 0 && index < words.count else { return nil }
        return words[index]
    }
    
    // Get total word count
    public func getWordCount() -> Int {
        guard !inputText.isEmpty else { return 0 }
        
        let trimmedInput = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else { return 0 }
        
        return trimmedInput.components(separatedBy: .whitespacesAndNewlines).count
    }
    
    func switchKeyboard(_ currentKeyboard: KeyboardType) {
        switch currentKeyboard {
        case .sona:
            switchToTextKeyboard()
        default:
            switchToSonaKeyboard()
        }
    }
    
    func switchToEmojiKeyboard() {
        currentKeyboard = .emoji
    }
    
    func switchToTextKeyboard() {
        currentKeyboard = .text
    }
    
    func switchToSonaKeyboard() {
        currentKeyboard = .sona
    }
    
    // MARK: - Keyboard Input Handling
    func handleKeyboardInput(_ key: String, callback: TextChangeCallback?) {
        lastPressedKey = key
        if KeyboardLayout.isSpecialKey(key) {
            guard let specialKey = KeyboardLayout.getSpecialKey(for: key) else{
                return
            }
            handleSpecialKey(key, specialKey, callback)
        }else{
            handleTextKey(key,callback)
        }
    }
    
    private func handleTextKey(_ key: String,_ callback: TextChangeCallback? = nil) {
        // Add regular text characters to input
        inputText += key
        
        // Update last word typed
        updateLastWordTyped()
        
        callback?(KeyItem(value: key, key: nil))
        LogUtil.v(.KEYBOARD_INPUT_VM,"📝 KeyboardInputViewModel handleTextKey :: Added text: '\(key)' -> Current input: '\(inputText)', Last word: '\(lastWordTyped)'")
    }
    
    private func handleSpecialKey(_ key: String,_ specialKey: KeyboardLayout.SpecialKey,_ callback: TextChangeCallback? = nil) {
        
        switch specialKey {
        case .space:
            inputText += specialKey.keyValue
            updateLastWordTyped()
            callback?(KeyItem(value: specialKey.keyValue, key: specialKey))
            LogUtil.v(.KEYBOARD_INPUT_VM,"🎯 Added space -> Current input: '\(inputText)', Last word: '\(lastWordTyped)'")
        case .delete:
            if !inputText.isEmpty {
                inputText.removeLast()
                updateLastWordTyped()
                callback?(KeyItem(value: specialKey.keyValue, key: specialKey))
                LogUtil.v(.KEYBOARD_INPUT_VM,"🎯 Deleted character -> Current input: '\(inputText)', Last word: '\(lastWordTyped)'")
            }
            
        case .enter:
            LogUtil.v(.KEYBOARD_INPUT_VM,"🎯 Enter pressed -> Submit: '\(inputText)'")
            callback?(KeyItem(value: specialKey.keyValue, key: specialKey))
        case .shift:
            break
            // Shift state is handled internally by the keyboard
        case .numbers, .symbols, .letters:
            LogUtil.v(.KEYBOARD_INPUT_VM,"🎯 Switching keyboard mode to: \(specialKey)")
            
        case .globe:
            withAnimation(.easeInOut(duration: 0.3)) {
                currentKeyboard = .sona
            }
        case .dot:
            inputText += specialKey.keyValue
            updateLastWordTyped()
            callback?(KeyItem(value: specialKey.keyValue, key: specialKey))
        case .emoji:
            withAnimation(.easeInOut(duration: 0.3)) {
                currentKeyboard = .emoji
            }
        }
    }
    
    
    // MARK: - Emoji Handling
    func handleEmojiSelection(_ emoji: String, callback: TextChangeCallback? = nil) {
        if emoji == KeyboardLayout.SpecialKey.delete.rawValue {
            // Handle delete from emoji keyboard
            if !inputText.isEmpty {
                inputText.removeLast()
                updateLastWordTyped()
                callback?(KeyItem(value: emoji, key: nil))
            }
        } else {
            // Add emoji to input
            inputText += emoji
            updateLastWordTyped()
            callback?(KeyItem(value: emoji, key: nil))
        }
    }
    
    // MARK: - Text Replacement Handling
    func onSelectTextReplacement(with replacement: String, callback: TextChangeCallback? = nil) {
        replaceLastWordWith(replacement)
    }
}
