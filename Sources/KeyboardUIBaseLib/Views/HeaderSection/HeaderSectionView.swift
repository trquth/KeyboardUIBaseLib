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
    
    
    private let words: [String] = ["are", "and", "ask"]
    
    var body: some View {
        HStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                        WText(word)
                            .fontSize(17)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                        
                        // Add divider between words (not after the last word)
                        if index < words.count - 1 {
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
    HeaderSectionView(currentKeyboard: .constant(.text), onSwitchKeyboard: nil)
        
}
