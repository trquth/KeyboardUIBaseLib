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
            MainView()
        }
        .padding()
    }
}

#Preview {
   // test
    ContentView()
        .frame(height: 300)
        .loadCustomFonts()
}

#Preview("Text with Custom Font") {
    WText("New Font")
        .customFont(.zenLoopRegular, size: 30)
        .loadCustomFonts()
}
