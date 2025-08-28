//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 28/8/25.
//

import SwiftUI

extension View {
    func setupEnvironmentObjects (_ container: SonaAppContainer) -> some View {
            self.environmentObject(container.sonaVM)
            .environmentObject(container.loadingVM)
            .environmentObject(container.toastMessageVM)
            .environmentObject(container.sharedDataVM)
    }
    
    func setupApiConfig () -> some View {
        self.onAppear {
            ApiConfiguration.shared.configure(
                baseUrl: API_BASE_URL,
                refreshUrl: "\(API_BASE_URL)/Prod/api/auth/refresh"
            )
        }
    }
    
    func setupTokenApi(token: String, refreshToken: String)-> some View {
        self.onAppear {
            TokenAppStorageService.shared.saveTokens(
                accessToken: token,
                refreshToken: refreshToken
            )
        }
    }
}
