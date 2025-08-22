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
    private let onTextChanged: ((String) -> Void)?
    private let onKeyPressed: ((String) -> Void)?
    private let onTextSubmitted: ((String) -> Void)?
    private let onTextReplacementRequested: ((String) -> [TextReplacement])?
    private let onTextReplacementSelected: ((TextReplacement) -> Void)?
    
    // Text replacement view model
    @StateObject private var textReplacementsVM = TextReplacementVM()
    
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
            currentKeyboard: keyboardInputVM.currentKeyboard, 
            currentInput: keyboardInputVM.currentTypingInput,
            onSwitchKeyboard: { keyboardType in
                withAnimation(.easeInOut(duration: 0.3)) {
                    keyboardInputVM.switchKeyboard(keyboardType)
                }
            },
            textReplacements: textReplacementsVM.textReplacements,
            onTextReplacementSelected: { replacement in
                onTextReplacementSelected?(replacement)
            },
            onClearTextReplacements: {
                textReplacementsVM.textReplacements = []
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
                        key, inputText in
                        onTextChanged?(inputText)
                        onKeyPressed?(key)
                    }
                },
                onBackToKeyboard: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        keyboardInputVM.currentKeyboard = .text
                    }
                }
            )
        case .text:
            CustomKeyboardV2View { key, specialKey in
                keyboardInputVM.handleKeyboardInput(key: key, specialKey: specialKey){
                    key, inputText in
                    onTextChanged?(inputText)
                    onKeyPressed?(key)
                    
                }
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
                .animation(.easeInOut(duration: 0.3), value: keyboardInputVM.currentKeyboard)
        }

    }
}

#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @StateObject var keyboardInputVM = KeyboardInputVM()
    VStack {
        WText("INPUT TEXT (Length: \(keyboardInputVM.inputText.count)) \n\(keyboardInputVM.inputText)")
            
        MainView(
            onTextChanged: { text in
            },
            onKeyPressed: { key in
            },
            onTextSubmitted: { text in
            }
        ).keyboardFrame()
    }

    .loadCustomFonts()
    .environmentObject(keyboardInputVM)
}

#Preview("Text"){
    WText("New Font")
        .font(.custom(.zenLoopRegular, size: 22))
        .loadCustomFonts()
}
