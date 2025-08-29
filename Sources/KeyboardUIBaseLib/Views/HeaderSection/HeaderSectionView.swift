//
//  HeaderSectionView.swift
//  BaseKeyboard
//
//  Created by Thien Tran-Quan on 15/8/25.
//

import SwiftUI

struct HeaderSectionView: View {
    @EnvironmentObject private var keyboardInputVM: KeyboardInputVM
    @EnvironmentObject private var sharedDataVM: SharedDataViewModel
    
    // Text replacement suggestions
    let onTextReplacementSelected: ((TextReplacement) -> Void)?
    
    private  func findTextReplacements(for shortcut: String) -> [TextReplacement]{
        let textReplacements = sharedDataVM.textReplacements
        if shortcut.isEmpty || textReplacements.isEmpty {
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
        findTextReplacements(for:keyboardInputVM.currentTypingInput)
    }
    
    private var filteredSuggestionsCount: Int {
        return filteredSuggestions.count
    }
    
    var body: some View {
        HStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(Array(filteredSuggestions.enumerated()), id: \.element.id) { index, suggestion in
                        Button{
                            onTextReplacementSelected?(suggestion)
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
                withAnimation(.easeInOut(duration: 0.3)) {              keyboardInputVM.switchKeyboard(keyboardInputVM.currentKeyboard)
                }
            }
        }
        .padding(.horizontal, 16)
        .onAppear {
            print("Typing input change ::::: \(sharedDataVM.currentTypingInput)")
        }
    }
}

#Preview {
    let sampleReplacements = [
        TextReplacement(shortcut: "omw", replacement: "On my way!"),
        TextReplacement(shortcut: "brb", replacement: "Be right back"),
        TextReplacement(shortcut: "lol", replacement: "😂"),
        TextReplacement(shortcut: "addr", replacement: "123 Main Street, City, State 12345")
    ]
    HeaderSectionView {
        print("Selected replacement: \($0.replacement)")
    }.environmentObject(KeyboardInputVM(currentTypingInput: "lol"))
            .environmentObject(SharedDataViewModel(textReplacements: sampleReplacements))
    
}
