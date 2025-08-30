//
//  SwiftUIView.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 29/8/25.
//

import SwiftUI

struct NormalKeyboardApp: View {
    @EnvironmentObject private var keyboardInputVM: KeyboardInputViewModel
    @EnvironmentObject private var sharedDataVM: SharedDataViewModel
    
    @Binding var currentKeyboard: KeyboardType
    
    @ViewBuilder
    private func renderKeyboard() -> some View {
        switch currentKeyboard {
        case .emoji:
            EmojiKeyboardView(currentKeyboard: $currentKeyboard) { emoji in
                keyboardInputVM.handleEmojiSelection(emoji) {
                   keyItem in
                    sharedDataVM.onPressKey(keyItem)
                }
            }
        default:
            NormalKeyboardView { key in
                keyboardInputVM.handleKeyboardInput(key){
                    keyItem in
                    sharedDataVM.onPressKey(keyItem)
                }
            }
        }
    }
    var body: some View {
        renderKeyboard()
    }
}

#Preview {
    @Previewable @StateObject var container = SonaAppContainer(container: DIContainer.shared)
    NormalKeyboardApp(currentKeyboard: .constant(.text))
        .keyboardFramePreview()
        .keyboardBorderPreview()
        .setupNormalKeyboardEnvironmentObjectsPreview(container)
}
