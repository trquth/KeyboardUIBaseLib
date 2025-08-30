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
    
    @State private var showSupportedLanguages = false
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        ZStack {
            // Main content
            VStack {
                QuickTaskView()
                //suggestionInput
                WVSpacer(43)
                TonesView()
            }.allowsHitTesting(!loadingVM.isLoading)

            
            // Overlay SupportedLanguagesView
            if showSupportedLanguages {
                SupportedLanguagesView { language in
                    withAnimation(.easeOut(duration: 0.3)) {
                        showSupportedLanguages = false
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // Overlay DeleteToneConfirmationModal
            if showDeleteConfirmation {
                DeleteToneConfirmationModal(
                    title: "Delete Tone?",
                    onCancel: {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showDeleteConfirmation = false
                        }
                    },
                    onDelete: {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showDeleteConfirmation = false
                        }
                        // Add delete logic here
                        print("Tone deleted")
                    }
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(height: 225)
        .displayToastMessage(toastMessageVM)
        
    }
}

#Preview {
    @Previewable @StateObject var container = SonaAppContainer(container: DIContainer.shared)

    SonaKeyboardView()
        .keyboardFramePreview()
        .setupEnvironmentObjectsPreview(container)
        .setupApiConfigPreview()
        .setupTokenApiPreview() 
}
