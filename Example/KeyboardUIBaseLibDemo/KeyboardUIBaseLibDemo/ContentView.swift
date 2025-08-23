//
//  ContentView.swift
//  KeyboardUIBaseLibDemo
//
//  Created by Thien Tran-Quan on 20/8/25.
//

import SwiftUI
import KeyboardUIBaseLib

struct ContentView: View {
    var body: some View {
        VStack {
            Spacer()
                
            MainView(
                onKeyPressed: { key in
                    print("⌨️ Key pressed: '\(key)'")
                },
                onTextSubmitted: { text in
                    print("✅ Text submitted: '\(text)'")
                }
            )
        }
    }
}

#Preview {
    ContentView()
        .frame(height: 300)
        .loadCustomFonts()
}

#Preview("Text with Custom Font") {
    WText("New Font")
        .customFont(.zenLoopRegular, size: 30)
        .loadCustomFonts()
}
