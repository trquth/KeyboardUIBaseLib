//
//  MainView.swift
//  BaseKeyboard
//
//  Created by Thien Tran-Quan on 17/8/25.
//

import SwiftUI

// MARK: - Keyboard Types
enum KeyboardType {
    case text        // CustomKeyboardV2View
    case emoji       // EmojiKeyboardView
    case sona        // SonaKeyboardView
}

public struct MainView: View {
    @State private var inputText: String = ""
    @State private var lastPressedKey: String = ""
    @State private var currentKeyboard: KeyboardType = .text
    @State private var currentTypingInput: String = ""
    
    // Callback functions
    private let onTextChanged: ((String) -> Void)?
    private let onKeyPressed: ((String) -> Void)?
    private let onTextSubmitted: ((String) -> Void)?
    private let onTextReplacementRequested: ((String) -> [TextReplacement])?
    private let onTextReplacementSelected: ((TextReplacement) -> Void)?
    
    // Text replacement suggestions
    @State private var textReplacements: [TextReplacement] = []
    
    public init(
        onTextChanged: ((String) -> Void)? = nil,
        onKeyPressed: ((String) -> Void)? = nil,
        onTextSubmitted: ((String) -> Void)? = nil,
        onTextReplacementRequested: ((String) -> [TextReplacement])? = nil,
        onTextReplacementSelected: ((TextReplacement) -> Void)? = nil
    ) {
        self.onTextChanged = onTextChanged
        self.onKeyPressed = onKeyPressed
        self.onTextSubmitted = onTextSubmitted
        self.onTextReplacementRequested = onTextReplacementRequested
        self.onTextReplacementSelected = onTextReplacementSelected
    }
    
    private var header : some View {
        HeaderSectionView(
            currentKeyboard: $currentKeyboard, 
            onSwitchKeyboard: { keyboardType in
                switch keyboardType {
                case .sona:
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentKeyboard = .text
                    }
                default:
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentKeyboard = .sona
                    }
                }
            },
            textReplacements: textReplacements,
            currentInput: currentTypingInput,
            onTextReplacementSelected: { replacement in
                onTextReplacementSelected?(replacement)
            }
        )
    }
    
    @ViewBuilder
    private var keyboard: some View {
        switch currentKeyboard {
        case .emoji:
            EmojiKeyboardView(
                onEmojiSelected: { emoji in
                    handleEmojiSelection(emoji)
                },
                onBackToKeyboard: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentKeyboard = .text
                    }
                }
            )
        case .text:
            CustomKeyboardV2View { key, specialKey in
                handleKeyboardInput(key: key, specialKey: specialKey)
            }
        case .sona:
            SonaKeyboardView()
        }
    }
    
   public var body: some View {
        VStack(spacing: 0) {  
            WVSpacer(10)
            header
            WVSpacer(2)
            WSpacer()
            keyboard
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .move(edge: .bottom).combined(with: .opacity)
                ))
                .animation(.easeInOut(duration: 0.3), value: currentKeyboard)
        }

    }
    
    // MARK: - Emoji Handling
    private func handleEmojiSelection(_ emoji: String) {
        if emoji == "⌫" {
            // Handle delete from emoji keyboard
            if !inputText.isEmpty {
                inputText.removeLast()
                onTextChanged?(inputText)
                onKeyPressed?("⌫")
                print("🎯 Deleted character from emoji keyboard -> Current input: '\(inputText)'")
            }
        } else {
            // Add emoji to input
            inputText += emoji
            onTextChanged?(inputText)
            onKeyPressed?(emoji)
            print("😀 Added emoji: '\(emoji)' -> Current input: '\(inputText)'")
        }
    }
    
    // MARK: - Keyboard Input Handling
    private func handleKeyboardInput(key: String, specialKey: KeyboardLayout.SpecialKey?) {
        lastPressedKey = key
        
        if let specialKey = specialKey {
            handleSpecialKey(key: key, specialKey: specialKey)
        } else {
            handleTextKey(key)
        }
    }
    
    private func handleTextKey(_ key: String) {
        // Add regular text characters to input
        inputText += key
        
        // Update current typing input for text replacement suggestions
        updateCurrentTypingInput()
        
        onTextChanged?(inputText)
        onKeyPressed?(key)
        print("📝 Added text: '\(key)' -> Current input: '\(inputText)'")
        print("🔍 Current typing input: '\(currentTypingInput)'")
    }
    
    private func updateCurrentTypingInput() {
        // Get the current word being typed (characters after the last space/punctuation)
        let separators = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        let words = inputText.components(separatedBy: separators)
        currentTypingInput = words.last ?? ""
        
        // Request text replacement suggestions from the keyboard controller
        if let replacements = onTextReplacementRequested?(currentTypingInput) {
            textReplacements = replacements
        }
    }
    
    private func handleSpecialKey(key: String, specialKey: KeyboardLayout.SpecialKey) {
        onKeyPressed?(key)
        
        switch specialKey {
        case .space:
            inputText += " "
            currentTypingInput = "" // Clear typing input on space
            textReplacements = [] // Clear text replacement suggestions
            onTextChanged?(inputText)
            print("🎯 Added space -> Current input: '\(inputText)'")
            
        case .delete:
            if !inputText.isEmpty {
                inputText.removeLast()
                updateCurrentTypingInput() // Update typing input after delete
                onTextChanged?(inputText)
                print("🎯 Deleted character -> Current input: '\(inputText)'")
            }
            
        case .enter:
            print("🎯 Enter pressed -> Submit: '\(inputText)'")
            onTextSubmitted?(inputText)
            // Handle text submission here
            // inputText = "" // Optionally clear input
            
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
            onTextChanged?(inputText)
            print("🎯 Added dot -> Current input: '\(inputText)'")
            
        case .emoji:
            print("🎯 Emoji button pressed")
            withAnimation(.easeInOut(duration: 0.3)) {
                currentKeyboard = .emoji
            }
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    MainView(
        onTextChanged: { text in
            print("📱 Text changed: '\(text)'")
        },
        onKeyPressed: { key in
            print("⌨️ Key pressed: '\(key)'")
        },
        onTextSubmitted: { text in
            print("✅ Text submitted: '\(text)'")
        }
    )
    .background(Color.white)
    .frame(height: 300)
    .background(.pink)
    .border(Color.yellow, width: 1)
    .loadCustomFonts()
}

#Preview("Text"){
    WText("New Font")
        .font(.custom(.zenLoopRegular, size: 22))
        .loadCustomFonts()
}
