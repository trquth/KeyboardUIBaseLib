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
                accessToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2OGFjMmU4YmQwZWUxMzIwMDMzZTVjMTgiLCJpYXQiOjE3NTYzNDY2NjQsImV4cCI6MTc1Njk1MTQ2NCwiYXVkIjoic29uYS1hcHAiLCJpc3MiOiJzb25hLWFwaSJ9.IBjvrFbnDt9TsrpbLo1Vdv_9RitwYp8KiULDJ2vxY2M",
                refreshToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2OGFjMmU4YmQwZWUxMzIwMDMzZTVjMTgiLCJpYXQiOjE3NTYxMTQ1NzEsImV4cCI6MTc1NjcxOTM3MSwiYXVkIjoic29uYS1hcHAiLCJpc3MiOiJzb25hLWFwaSJ9.2kS5aCSYIX1oP22W4QWQETG-ZbHD942Y2lkokdq_phs"
            )
        }
    }
}
