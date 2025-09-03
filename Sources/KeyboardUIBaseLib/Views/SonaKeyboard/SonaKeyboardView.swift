//
//  SonaKeyboardView.swift
//  BaseKeyboard
//
//  Created by Thien Tran-Quan on 15/8/25.
//

import SwiftUI
import Alamofire

struct SonaKeyboardView: View {
    @EnvironmentObject private var toastMessageVM: ToastMessageManager
    @EnvironmentObject private var loadingVM: LoadingViewModel
    
    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                ToneAndPersonaView()
                QuickTaskView()
            }.allowsHitTesting(!loadingVM.isLoading)
        }
        .frame(height: 225)
        .displayToastMessage(toastMessageVM)
        
    }
}

#Preview {
    @Previewable @StateObject var container = SonaAppContainer(container: DIContainer.shared)
    

    SonaKeyboardView()
        .keyboardFramePreview()
        .environmentObject(KeyboardInputViewModel(inputText: "I AM HERO"))
        .setupEnvironmentObjectsPreview(container)
        .setupApiConfigPreview()
        .setupTokenApiPreview() 
}
