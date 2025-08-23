//
//  HeaderSectionView.swift
//  BaseKeyboard
//
//  Created by Thien Tran-Quan on 15/8/25.
//

import SwiftUI

struct HeaderSectionView: View {
    @EnvironmentObject private var keyboardInputVM: KeyboardInputVM
    @EnvironmentObject private var textReplacementVM: TextReplacementVM
    
    // Text replacement suggestions
    let onTextReplacementSelected: ((TextReplacement) -> Void)?
    
    init(
        onTextReplacementSelected: ((TextReplacement) -> Void)? = nil
    ) {
        self.onTextReplacementSelected = onTextReplacementSelected
    }
    
    // Filter suggestions based on current input
    private var filteredSuggestions: [TextReplacement] {
        textReplacementVM.findTextReplacements(for:keyboardInputVM.currentTypingInput)
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
            SwitchKeyboardButton()
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    let sampleReplacements = [
        TextReplacement(shortcut: "omw", replacement: "On my way!"),
        TextReplacement(shortcut: "brb", replacement: "Be right back"),
        TextReplacement(shortcut: "lol", replacement: "😂"),
        TextReplacement(shortcut: "addr", replacement: "123 Main Street, City, State 12345")
    ]
    
    HeaderSectionView(
        onTextReplacementSelected: { replacement in
            print("Selected: \(replacement.shortcut) -> \(replacement.replacement)")
        }
    ).environmentObject(KeyboardInputVM(inputText: "lol"))
        .environmentObject(TextReplacementVM(textReplacements: sampleReplacements))
        
}
