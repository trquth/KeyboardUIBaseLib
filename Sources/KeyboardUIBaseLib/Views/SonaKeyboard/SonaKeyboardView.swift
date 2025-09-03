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
        VStack(spacing: 5) {
            ToneAndPersonaView()
            QuickTaskView()
            WSpacer()
        }
        .allowsHitTesting(!loadingVM.isLoading)
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
