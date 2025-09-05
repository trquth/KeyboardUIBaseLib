//
//  SonayKeyboardApp.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 26/8/25.
//

import SwiftUI

struct SonayKeyboardApp: View {
    @StateObject private var container = SonaAppContainer(container: DIContainer.shared)
    
    var body: some View {
        SonaKeyboardView()
            .setupEnvironmentObjects(container)
            .setupApiConfig()
    }
}

#Preview {
    @Previewable @StateObject var keyboardVM = KeyboardInputViewModel(inputText: "I AM HERO")
    
    SonayKeyboardApp()
        .environmentObject(keyboardVM)
        .keyboardBorderPreview()
        .setupTokenApiPreview()
      
        
}
