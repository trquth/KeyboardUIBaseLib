//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 22/8/25.
//

import SwiftUI

extension View {
    func keyboardFramePreview()-> some View {
        self.frame(height: KeyboardConfiguration.KEYBOARD_HEIGHT)
            .border(.yellow, width: 1)
    }
    
    func keyboardBorderPreview()-> some View {
        self.border(.yellow, width: 1)
    }
    
    func setupEnvironmentObjectsPreview (_ container: SonaAppContainer) -> some View {
            self.environmentObject(container.sonaVM)
            .environmentObject(container.loadingVM)
            .environmentObject(container.toastMessageVM)
            .environmentObject(container.sharedDataVM)
    }
    
    func setupNormalKeyboardEnvironmentObjectsPreview(_ container: SonaAppContainer) -> some View {
        self.environmentObject(container.keyboardVM)
            .environmentObject(container.sharedDataVM)

    }
    
    func setupKeyboardVMEnvironmentObjectPreview(_ currentText: String) -> some View {
        self.environmentObject(KeyboardInputVM(inputText: currentText))
    }
    
    func setupApiConfigPreview () -> some View {
        self.onAppear {
            ApiConfiguration.shared.configure(
                baseUrl: API_BASE_URL,
                refreshUrl: "\(API_BASE_URL)/Prod/api/auth/refresh"
            )
        }
    }
    
    func setupTokenApiPreview ()-> some View {
        self.onAppear {
            TokenAppStorageService.shared.saveTokens(
                accessToken: DEMO_ACCESS_TOKEN,
                refreshToken: REFRESH_TOKEN
            )
        }
    }
}
