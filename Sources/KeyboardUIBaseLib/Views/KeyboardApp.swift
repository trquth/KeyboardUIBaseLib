//
//  SwiftUIView.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 22/8/25.
//

import SwiftUI

struct KeyboardApp: View {
    private var keyboardInputVM = KeyboardInputVM()
    
    // Callback functions
    private let onTextChanged: ((String) -> Void)?
    private let onKeyPressed: ((String) -> Void)?
    private let onTextSubmitted: ((String) -> Void)?
    private let onTextReplacementRequested: ((String) -> [TextReplacement])?
    private let onTextReplacementSelected: ((TextReplacement) -> Void)?
    
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
    
    
    var body: some View {
        MainView( onKeyPressed: self.onKeyPressed,
        onTextSubmitted: self.onTextSubmitted,
        onTextReplacementRequested: self.onTextReplacementRequested,
                  onTextReplacementSelected: self.onTextReplacementSelected).environmentObject(keyboardInputVM)
    }
}

#Preview {
    @Previewable @StateObject var keyboardInputVM = KeyboardInputVM()
    VStack {
        WText("INPUT TEXT (Length: \(keyboardInputVM.inputText.count)) \n\(keyboardInputVM.inputText)")
            
        KeyboardApp(  onTextChanged: { text in
            print("📱 KeyboardApp Text changed: '\(text)'")
        },
        onKeyPressed: { key in
            print("⌨️ KeyboardApp Key pressed: '\(key)'")
        },
        onTextSubmitted: { text in
            print("✅ KeyboardApp Text submitted: '\(text)'")
        }).keyboardFrame().environmentObject( keyboardInputVM)
    }
  
}

