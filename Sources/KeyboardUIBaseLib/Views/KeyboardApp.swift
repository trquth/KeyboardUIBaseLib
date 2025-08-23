//
//  SwiftUIView.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 22/8/25.
//

import SwiftUI

struct KeyboardApp: View {
    // Callback functions
    private let onKeyPressed: ((KeyItem) -> Void)?
    private let onTextSubmitted: ((String) -> Void)?
    private let onTextReplacementSelected: ((TextReplacement) -> Void)?
    
    public init(
        onKeyPressed: ((KeyItem) -> Void)? = nil,
        onTextSubmitted: ((String) -> Void)? = nil,
        onTextReplacementSelected: ((TextReplacement) -> Void)? = nil
    ) {
        self.onKeyPressed = onKeyPressed
        self.onTextSubmitted = onTextSubmitted
        self.onTextReplacementSelected = onTextReplacementSelected
    }
    
    
    var body: some View {
        MainView(
            onKeyPressed: self.onKeyPressed,
            onTextSubmitted: self.onTextSubmitted,
            onTextReplacementSelected:
                self.onTextReplacementSelected)
    }
}

#Preview {
    VStack {  
        KeyboardApp(
                      onKeyPressed: { key in
            print("⌨️ KeyboardApp Key pressed: '\(key)'")
        },
                      onTextSubmitted: { text in
            print("✅ KeyboardApp Text submitted: '\(text)'")
                      }).keyboardFramePreview()
    }
    
}

