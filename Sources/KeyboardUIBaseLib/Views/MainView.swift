//
//  MainView.swift
//  BaseKeyboard
//
//  Created by Thien Tran-Quan on 17/8/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var keyboardInputVM: KeyboardInputViewModel
    @EnvironmentObject private var sharedDataVM: SharedDataViewModel
    
    private func renderHeaderSection() -> some View {
        HeaderSectionView()
    }
    
    @ViewBuilder
    private func renderKeyboard() -> some View {
        switch keyboardInputVM.currentKeyboard {
        case .emoji, .text:
            NormalKeyboardApp(currentKeyboard: $keyboardInputVM.currentKeyboard)
        case .sona:
            SonayKeyboardApp()
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            WVSpacer(10)
            renderHeaderSection()
            WVSpacer(2)
            WSpacer()
            renderKeyboard()
                .keyboardAnimation( keyboardInputVM.currentKeyboard)
        }.onChangeCompact(of: sharedDataVM.inputTextFieldValue) { value in
            LogUtil.v(.MainView, "onChangeCompact inputTextFieldValue initializeInputText ::: \(value)")
            keyboardInputVM.initializeInputText(value)
        }.onChangeCompact(of: sharedDataVM.translatedText) { value in
            LogUtil.v(.MainView,"onChangeCompact AI generation translatedText ::: \(value)")
            if !value.isEmpty {
                keyboardInputVM.setInputText(value)
            }
        }
    }
}

extension View {
    func keyboardAnimation(_ keyboard: KeyboardType ) -> some View {
        self.transition(.asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        ))
        .animation(.easeInOut(duration: 0.3), value: keyboard)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @StateObject var keyboardInputVM = KeyboardInputViewModel(lastWordTyped: "lol")
    
    @Previewable @StateObject var container = SonaAppContainer(container: DIContainer.shared)
    
    
    let sampleReplacements = [
        TextReplacement(shortcut: "clgt", replacement: "Cau lam gi the"),
        TextReplacement(shortcut: "omw", replacement: "On my way!"),
        TextReplacement(shortcut: "brb", replacement: "Be right back"),
        TextReplacement(shortcut: "lol", replacement: "😂"),
        TextReplacement(shortcut: "addr", replacement: "123 Main Street, City, State 12345")
    ]
    
    VStack {
        WText("INPUT TEXT (Length: \(keyboardInputVM.inputText.count)) \n\(keyboardInputVM.inputText)")
        
        MainView()
            .keyboardFramePreview()
    }
    //.loadCustomFonts()
    //.setupNormalKeyboardEnvironmentObjectsPreview(container)
    .environmentObject(keyboardInputVM)
    .environmentObject(SharedDataViewModel(textReplacements: sampleReplacements))
}

#Preview("Text"){
    WText("New Font")
        .font(.custom(.zenLoopRegular, size: 22))
        .loadCustomFonts()
}
