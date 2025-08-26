//
//  SonayKeyboardApp.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 26/8/25.
//

import SwiftUI

struct SonayKeyboardApp: View {
    @StateObject private var sonaContainer = SonaAppContainer()
    
    var body: some View {
        SonaKeyboardView()
            .environmentObject(sonaContainer.sonaVM)
            .environmentObject(sonaContainer.loadingVM)
    }
}

#Preview {
    SonayKeyboardApp()
        .keyboardBorderPreview()
}
