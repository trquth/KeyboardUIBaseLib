//
//  HeaderSectionView.swift
//  BaseKeyboard
//
//  Created by Thien Tran-Quan on 15/8/25.
//

import SwiftUI

struct HeaderSectionView: View {
    @EnvironmentObject private var keyboardInputVM: KeyboardInputViewModel
    @EnvironmentObject private var sharedDataVM: SharedDataViewModel
    
    private  func findTextReplacements(for shortcut: String) -> [TextReplacement]{
        if shortcut.isEmpty {
            return []
        }
        let textReplacements = sharedDataVM.textReplacements
        if  textReplacements.isEmpty {
            return []
        }
        // Filter text replacements based on the shortcut
        let filtered = textReplacements.filter { replacement in
            replacement.shortcut.lowercased().hasPrefix(shortcut.lowercased())
        }
        
        return Array(filtered.prefix(5)) // Show up to 5 matching suggestions
    }
    
    // Filter suggestions based on current input
    private var filteredSuggestions: [TextReplacement] {
        findTextReplacements(for:keyboardInputVM.lastWordTyped)
    }
    
    private var filteredSuggestionsCount: Int {
        return filteredSuggestions.count
    }
    
    private func onSelectTextReplacement(_ replacement: TextReplacement) {
        keyboardInputVM.onSelectTextReplacement(with: replacement.replacement)
        //
        sharedDataVM.setSelectedTextReplacement(replacement)
        sharedDataVM.onPressKey(KeyItem(value: KeyboardLayout.SpecialKey.space.rawValue, key: KeyboardLayout.SpecialKey.space))
    }
    
    private func renderInputTextPreview() -> some View {
        WText(keyboardInputVM.inputText)
            .fontSize(10)
            .color(.red)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            renderInputTextPreview()
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(Array(filteredSuggestions.enumerated()), id: \.element.id) { index, suggestion in
                            Button{
                                onSelectTextReplacement(suggestion)
                            }label: {
                                WText(suggestion.replacement)
                                    .fontSize(17)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 16)
                            }
                            // Add divider between words (not after the last word)
                            if index < filteredSuggestionsCount - 1 {
                                Divider()
                                    .frame(height: 20)
                                    .background(Color.gray.opacity(0.3))
                                    .padding(.horizontal, 5)
                            }
                        }
                    }
                }
                WSpacer()
                SwitchKeyboardButton{
                    withAnimation(.easeInOut(duration: 0.3)) {    keyboardInputVM.switchKeyboard(keyboardInputVM.currentKeyboard)
                    }
                }
            }

        }
        .padding(.horizontal, 16)
//        .onAppear {
//            print("Typing input change ::::: \(sharedDataVM.currentTypingInput)")
//        }
    }
}

#Preview {
    let sampleReplacements = [
        TextReplacement(shortcut: "omw", replacement: "On my way!"),
        TextReplacement(shortcut: "brb", replacement: "Be right back"),
        TextReplacement(shortcut: "lol", replacement: "😂"),
        TextReplacement(shortcut: "addr", replacement: "123 Main Street, City, State 12345")
    ]
    HeaderSectionView ().environmentObject(KeyboardInputViewModel(lastWordTyped: "lol"))
            .environmentObject(SharedDataViewModel(textReplacements: sampleReplacements))
    
}
