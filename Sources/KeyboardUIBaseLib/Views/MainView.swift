//
//  MainView.swift
//  BaseKeyboard
//
//  Created by Thien Tran-Quan on 17/8/25.
//

import SwiftUI

public struct MainView: View {
    @EnvironmentObject private var keyboardInputVM: KeyboardInputVM
    
    // Callback functions
    private let onKeyPressed: ((KeyItem) -> Void)?
    private let onTextSubmitted: ((String) -> Void)?
    private let onTextReplacementSelected: ((TextReplacement) -> Void)?
    
    // Text replacement view model
    @StateObject private var textReplacementsVM = TextReplacementVM()
    
    public init(
        onKeyPressed: ((KeyItem) -> Void)? = nil,
        onTextSubmitted: ((String) -> Void)? = nil,
        onTextReplacementSelected: ((TextReplacement) -> Void)? = nil
    ) {
        self.onKeyPressed = onKeyPressed
        self.onTextSubmitted = onTextSubmitted
        self.onTextReplacementSelected = onTextReplacementSelected
    }
    
    private var header : some View {
        HeaderSectionView(
            onTextReplacementSelected: { replacement in
                onTextReplacementSelected?(replacement)
                onKeyPressed?(KeyItem(value: KeyboardLayout.SpecialKey.space.rawValue, key: KeyboardLayout.SpecialKey.space))
            }
        )
    }
    
    @ViewBuilder
    private var keyboard: some View {
        switch keyboardInputVM.currentKeyboard {
        case .emoji:
            EmojiKeyboardView(
                onEmojiSelected: { emoji in
                    keyboardInputVM.handleEmojiSelection(emoji) {
                       keyItem in
                        onKeyPressed?(keyItem)
                    }
                },
                onBackToKeyboard: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        keyboardInputVM.currentKeyboard = .text
                    }
                }
            )
        case .text:
            CustomKeyboardV2View { key in
                keyboardInputVM.handleKeyboardInput(key){
                    keyItem in
                    print("Input Text Updated key item :: key = \(keyItem.value)")
                    onKeyPressed?(keyItem)
                }
            }
        case .sona:
            //SonaKeyboardView()
            SonayKeyboardApp()
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
                .animation(.easeInOut(duration: 0.3), value: keyboardInputVM.currentKeyboard)
        }

    }
}

#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @StateObject var keyboardInputVM = KeyboardInputVM()
    
    
    let sampleReplacements = [
        TextReplacement(shortcut: "clgt", replacement: "Cau lam gi the"),
        TextReplacement(shortcut: "omw", replacement: "On my way!"),
        TextReplacement(shortcut: "brb", replacement: "Be right back"),
        TextReplacement(shortcut: "lol", replacement: "😂"),
        TextReplacement(shortcut: "addr", replacement: "123 Main Street, City, State 12345")
    ]
    
    VStack {
        WText("INPUT TEXT (Length: \(keyboardInputVM.inputText.count)) \n\(keyboardInputVM.inputText)")
            
        MainView(
            onKeyPressed: { key in
                keyboardInputVM.currentTypingInput = key.value
            },
            onTextSubmitted: { text in
            },
            onTextReplacementSelected: { replacement in
                print("📋 Text Replacement Selected: '\(replacement.shortcut)' -> '\(replacement.replacement)'")
                keyboardInputVM.inputText = replacement.replacement
                keyboardInputVM.resetCurrentTypingInput()
            }
        ).keyboardFramePreview()
    }
    .loadCustomFonts()
    .environmentObject(keyboardInputVM)
    .environmentObject(TextReplacementVM(textReplacements: sampleReplacements))
}

#Preview("Text"){
    WText("New Font")
        .font(.custom(.zenLoopRegular, size: 22))
        .loadCustomFonts()
}
