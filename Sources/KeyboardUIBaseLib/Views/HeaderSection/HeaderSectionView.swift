//
//  HeaderSectionView.swift
//  BaseKeyboard
//
//  Created by Thien Tran-Quan on 15/8/25.
//

import SwiftUI

struct HeaderSectionView: View {
    @Binding var currentKeyboard: KeyboardType
    // Callback for switching back to text keyboard
    let onSwitchKeyboard: ((KeyboardType) -> Void)?
    
    // Text replacement suggestions
    let textReplacements: [TextReplacement]
    let currentInput: String
    let onTextReplacementSelected: ((TextReplacement) -> Void)?
    
    init(
        currentKeyboard: Binding<KeyboardType>,
        onSwitchKeyboard: ((KeyboardType) -> Void)? = nil,
        textReplacements: [TextReplacement] = [],
        currentInput: String = "",
        onTextReplacementSelected: ((TextReplacement) -> Void)? = nil
    ) {
        self._currentKeyboard = currentKeyboard
        self.onSwitchKeyboard = onSwitchKeyboard
        self.textReplacements = textReplacements
        self.currentInput = currentInput
        self.onTextReplacementSelected = onTextReplacementSelected
    }
    
    
    
    // Filter suggestions based on current input
    private var filteredSuggestions: [TextReplacement] {
        if currentInput.isEmpty {
            return []
        }
        
        let filtered = textReplacements.filter { replacement in
            replacement.shortcut.lowercased().hasPrefix(currentInput.lowercased())
        }
        
        return Array(filtered.prefix(5)) // Show up to 5 matching suggestions
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
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 1, height: 20)
                        }
                    }
                }
            }   
            Spacer()
            
            Circle()
                .fill(Color.black)
                .frame(width: 42, height: 42)
                .onTapGesture {
                    print("Switching to text keyboard \($currentKeyboard)")
                    onSwitchKeyboard?(currentKeyboard)
                }
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
    
    return HeaderSectionView(
        currentKeyboard: .constant(.text),
        onSwitchKeyboard: nil,
        textReplacements: sampleReplacements,
        currentInput: "o",
        onTextReplacementSelected: { replacement in
            print("Selected: \(replacement.shortcut) -> \(replacement.replacement)")
        }
    )
}
