//
//  KeyboardInputVM.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 22/8/25.
//

import Foundation
import SwiftUI

typealias TextChangeCallback = (KeyItem) -> Void

public class KeyboardInputVM: ObservableObject {
    @Published public var inputText: String = ""
    @Published public var lastPressedKey: String = ""
    @Published public var currentKeyboard: KeyboardType = .text
    @Published public var currentTypingInput: String = ""
    
    public init() {
    }
    
    public init(inputText: String) {
        self.inputText = inputText
    }
    
    func clearInputText() {
        if !inputText.isEmpty {
            inputText = ""
        }
    }
    
    public func resetCurrentTypingInput() {
        if !currentTypingInput.isEmpty {
          currentTypingInput = ""
        }
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
        print("🔑 KeyboardInputVM handleKeyboardInput :: Key pressed: '\(key)' with special key: \(String(describing: KeyboardLayout.getSpecialKey(for: key) ?? .none))")
       
        
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
        
        //        // Update current typing input for text replacement suggestions
        //        updateCurrentTypingInput()
        callback?(KeyItem(value: key, key: nil))
        
        //        onTextChanged?(inputText)
        //        onKeyPressed?(key)
        print("📝 Added text: '\(key)' -> Current input: '\(inputText)'")
        //  print("🔍 Current typing input: '\(currentTypingInput)'")
    }
    
    private func handleSpecialKey(_ key: String,_ specialKey: KeyboardLayout.SpecialKey,_ callback: TextChangeCallback? = nil) {
        
        switch specialKey {
        case .space:
            inputText += specialKey.keyValue
            callback?(KeyItem(value: specialKey.keyValue, key: specialKey))
            print("🎯 Added space -> Current input: '\(inputText)'")
            
        case .delete:
            if !inputText.isEmpty {
                inputText.removeLast()
                callback?(KeyItem(value: specialKey.keyValue, key: specialKey))
                print("🎯 Deleted character -> Current input: '\(inputText)'")
            }
            
        case .enter:
            print("🎯 Enter pressed -> Submit: '\(inputText)'")
            callback?(KeyItem(value: specialKey.keyValue, key: specialKey))
        case .shift:
            print("🎯 Shift toggled")
            // Shift state is handled internally by the keyboard
            
        case .numbers, .symbols, .letters:
            print("🎯 Keyboard mode changed to: \(specialKey)")
            
        case .globe:
            print("🎯 Language/Globe pressed - Switching to Sona keyboard")
            withAnimation(.easeInOut(duration: 0.3)) {
                currentKeyboard = .sona
            }
            
        case .dot:
            inputText += specialKey.keyValue
            callback?(KeyItem(value: specialKey.keyValue, key: specialKey))
            print("🎯 Added dot -> Current input: '\(inputText)'")
            
        case .emoji:
            print("🎯 Emoji button pressed")
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
                callback?(KeyItem(value: emoji, key: nil))
                print("🎯 Deleted character from emoji keyboard -> Current input: '\(inputText)'")
            }
        } else {
            // Add emoji to input
            inputText += emoji
            callback?(KeyItem(value: emoji, key: nil))
            print("😀 Added emoji: '\(emoji)' -> Current input: '\(inputText)'")
        }
    }
    
    // MARK: - Text Replacement Handling
    func onSelectTextReplacement(with replacement: String, callback: TextChangeCallback? = nil) {
        inputText += replacement
        callback?(KeyItem(value: KeyboardLayout.SpecialKey.space.rawValue, key: KeyboardLayout.SpecialKey.space))
    }
}
