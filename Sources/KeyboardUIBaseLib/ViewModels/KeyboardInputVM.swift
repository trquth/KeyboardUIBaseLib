//
//  KeyboardInputVM.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 22/8/25.
//

import Foundation
import SwiftUI

typealias TextChangeCallback = (_ key: String,_ inputText: String) -> Void

public class KeyboardInputVM: ObservableObject {
    @Published public var inputText: String = ""
    @Published public var lastPressedKey: String = ""
    @Published public var currentKeyboard: KeyboardType = .text
    @Published public var currentTypingInput: String = ""
    
    public init() {
    }
    
    func clearInputText() {
        inputText = ""
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
    func handleKeyboardInput(key: String, specialKey: KeyboardLayout.SpecialKey?, callback: TextChangeCallback?) {
        print("🔑 Key pressed: '\(key)' with special key: \(String(describing: specialKey))")
        lastPressedKey = key
        
        if let specialKey = specialKey {
            handleSpecialKey(key: key, specialKey: specialKey)
        } else {
            handleTextKey(key,callback)
        }
    }
    
    private func handleTextKey(_ key: String,_ callback: TextChangeCallback? = nil) {
        // Add regular text characters to input
        inputText += key
        
        //        // Update current typing input for text replacement suggestions
        //        updateCurrentTypingInput()
        callback?(key, inputText)
        
        //        onTextChanged?(inputText)
        //        onKeyPressed?(key)
        print("📝 Added text: '\(key)' -> Current input: '\(inputText)'")
        //  print("🔍 Current typing input: '\(currentTypingInput)'")
    }
    
    private func handleSpecialKey(key: String, specialKey: KeyboardLayout.SpecialKey, callback: TextChangeCallback? = nil) {
        
        switch specialKey {
        case .space:
            inputText += " "
            callback?(key, inputText)
            print("🎯 Added space -> Current input: '\(inputText)'")
            
        case .delete:
            if !inputText.isEmpty {
                inputText.removeLast()
                callback?(key, inputText)
                print("🎯 Deleted character -> Current input: '\(inputText)'")
            }
            
        case .enter:
            print("🎯 Enter pressed -> Submit: '\(inputText)'")
            callback?(key, inputText)
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
            inputText += "."
            callback?(key, inputText)
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
        if emoji == "⌫" {
            // Handle delete from emoji keyboard
            if !inputText.isEmpty {
                inputText.removeLast()
                callback?(emoji, inputText)
                print("🎯 Deleted character from emoji keyboard -> Current input: '\(inputText)'")
            }
        } else {
            // Add emoji to input
            inputText += emoji
            callback?(emoji, inputText)
            print("😀 Added emoji: '\(emoji)' -> Current input: '\(inputText)'")
        }
    }
}
