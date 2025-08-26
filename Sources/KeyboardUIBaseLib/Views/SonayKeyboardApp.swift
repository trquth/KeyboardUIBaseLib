//
//  SonayKeyboardApp.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 26/8/25.
//

import SwiftUI

struct SonayKeyboardApp: View {
    @StateObject private var sonaContainer = SonaAppContainer(container: DIContainer.shared)
    
    var body: some View {
        SonaKeyboardView()
            .environmentObject(sonaContainer)
    }
}

#Preview {
    SonayKeyboardApp()
        .keyboardBorderPreview()
}
