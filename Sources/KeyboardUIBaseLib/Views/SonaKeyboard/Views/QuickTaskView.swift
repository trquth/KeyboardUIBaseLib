//
//  QuickTaskView.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 26/8/25.
//

import SwiftUI

struct QuickTaskView: View {
    @EnvironmentObject private var sonaVM: SonaViewModel
    @EnvironmentObject private var keyboardVM: KeyboardInputViewModel
    @EnvironmentObject private var toastMessageVM: ToastMessageManager
    @EnvironmentObject private var sharedDataVM: SharedDataViewModel
    
    @StateObject private var loadingVM = LoadingViewModel()
    
    
    private func onRewrite() async {
        do {
            loadingVM.startLoading()
            let message = keyboardVM.inputText
            let selectedTone = !sonaVM.selectedTone.isEmpty ? sonaVM.selectedTone : DEFAULT_SONA_TONE
            let selectedPersona = !sonaVM.selectedPersona.isEmpty ? sonaVM.selectedPersona : DEFAULT_SONA_PERSONA
            
            let params = RewriteRequestParam(message: message, tone: selectedTone, persona: selectedPersona)
            let data = try await sonaVM.rewriteText(params)
            let translatedText = data.output
            if !translatedText.isEmpty {
                LogUtil.d(.QUICK_TASKS_VIEW, "translated text '\(translatedText)'")
                sharedDataVM.setTranslatedText(translatedText)
                keyboardVM.setInputText(translatedText)
            }
            loadingVM.stopLoading()
        }catch {
            loadingVM.stopLoading()
            if let appError = error as? AppError {
                toastMessageVM.showError("\(appError.message)")
            } else {
                toastMessageVM.showError("\(error.localizedDescription)")
            }
            print("Error rewriting text: \(error)")
        }
    }
    
    private var isDisableRewriteButton: Bool {
        if keyboardVM.inputText.isEmpty {
            return true
        }
        return loadingVM.isLoading
    }
    
    private var isDisableButton: Bool {
        if keyboardVM.inputText.isEmpty {
            return true
        }
        return loadingVM.isLoading
    }
    
    private var rewriteButton: some View {
        QuickTaskButton("revert_ico"){
            Task {
                await onRewrite()
            }
        }.iconSize(width: 20.56, height: 18.91)
            .loading(loadingVM.isLoading)
            .disabled(isDisableRewriteButton)
    }
    
    private var goBackButton: some View {
        QuickTaskButton("go_back_ico"){
            
        }.iconSize(width: 14.41, height: 18.91)
            .loading(false)
            .disabled(isDisableButton)
    }
    
    private var forwardButton: some View {
        QuickTaskButton("forward_ico"){
            print("Forward action")
        }.iconSize(width: 14.41, height: 18.91)
            .loading(false)
            .disabled(isDisableButton)
    }
    
    private var copyButton: some View {
        QuickTaskButton("copy_ico"){
            print("Copy action")
        }.iconSize(width: 14.41, height: 18.91)
            .loading(false)
            .disabled(isDisableButton)
    }
    
    var body: some View {
        HStack(spacing:15) {
            goBackButton
            rewriteButton
            forwardButton
            copyButton
        }
        .allowsHitTesting(!loadingVM.isLoading)
        .onChangeCompact(of: sharedDataVM.inputText) { value in
            keyboardVM.setInputText(value)
        }
        //.displayToastMessage(toastMessageVM)
    }
}

#Preview {
    @Previewable var container = SonaAppContainer(container: DIContainer.shared)
    QuickTaskView()
        .setupKeyboardVMEnvironmentObjectPreview("I am hero")
        .setupCommonEnvironmentObjects(container)
        .setupEnvironmentObjectsPreview(container)
        .setupTokenApiPreview()
        .setupApiConfigPreview()
}
