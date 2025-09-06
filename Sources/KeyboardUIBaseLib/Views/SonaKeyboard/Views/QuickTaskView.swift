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
        
    @State private var loadingState: [String: Bool] = [:]
    
    private var historyConversationId : String? {
        return sonaVM.conversationHistory?.conversationId
    }
    
    private var historyPromptOutputId : String? {
        return sonaVM.conversationHistory?.promptOutputId
    }
    
    private func isEmptyConversationHistory() -> Bool {
        return historyConversationId == nil || historyPromptOutputId == nil
    }
    
    private var hasPrevConversation: Bool {
        return sonaVM.conversationHistory?.hasPrevious ?? false
    }
    
    private var hasNextConversation: Bool {
        return sonaVM.conversationHistory?.hasNext ?? false
    }
    
    private var isFirstConversation: Bool {
        return sonaVM.conversationHistory?.isFirst ?? false
    }
    
    private var isLastConversation: Bool {
        return sonaVM.conversationHistory?.isLast ?? false
    }
    
    private func onRewrite() async {
        do {
            showLoading("rewrite")
            let message = sonaVM.conversationHistory?.output ?? ""
            let selectedTone = !sonaVM.selectedTone.isEmpty ? sonaVM.selectedTone : DEFAULT_SONA_TONE
            let selectedPersona = !sonaVM.selectedPersona.isEmpty ? sonaVM.selectedPersona : DEFAULT_SONA_PERSONA
            
            var params = RewriteRequestParam(message: message, tone: selectedTone, persona: selectedPersona)
            
            if let prevConversationId = historyConversationId {
                params = RewriteRequestParam(message: message, tone: selectedTone, persona: selectedPersona, conversationId: prevConversationId)
            }
                    
            let data = try await sonaVM.rewriteText(params)
            LogUtil.d(.QUICK_TASKS_VIEW, "onRewrite :: response \(data)")
            let translatedText = data.output
            if !translatedText.isEmpty {
                LogUtil.d(.QUICK_TASKS_VIEW, "translated text '\(translatedText)'")
                sharedDataVM.setTranslatedText(translatedText)
                keyboardVM.setInputText(translatedText)
            }
            
            sonaVM.saveConversationHistory(data)
            hideLoading("rewrite")
        }catch {
            hideLoading("rewrite")
            if let appError = error as? AppError {
                toastMessageVM.showError("\(appError.message)")
            } else {
                toastMessageVM.showError("\(error.localizedDescription)")
            }
            print("Error rewriting text: \(error)")
        }
    }
    
    private func getConversation(for type: ConversationType) async {
        do {
            if let prevConversationId = historyConversationId,
               let prevPromptOutputId = historyPromptOutputId {
                showLoading(type.rawValue)
                let param = ConversationRequestParam(conversationId: prevConversationId, promptOutputId: prevPromptOutputId)
                
                let data = try await sonaVM.getConversation(for:type, data: param)
                LogUtil.d(.QUICK_TASKS_VIEW, "getConversation response :: '\(data)'")
                let translatedText = data.output
                if !translatedText.isEmpty {
                    LogUtil.d(.QUICK_TASKS_VIEW, "getConversation translated text '\(translatedText)'")
                    sharedDataVM.setTranslatedText(translatedText)
                    keyboardVM.setInputText(translatedText)
                }
                
                sonaVM.saveConversationHistory(data)
                
                hideLoading(type.rawValue)
            }
        }catch {
            hideLoading(type.rawValue)
            if let appError = error as? AppError {
                toastMessageVM.showError("\(appError.message)")
            } else {
                toastMessageVM.showError("\(error.localizedDescription)")
            }
            print("Error rewriting text: \(error)")
        }
    }
    
    private func copyTextToClipboard() {
        let text = sharedDataVM.translatedText
        if !text.isEmpty {
            LogUtil.d(.QUICK_TASKS_VIEW, "Copy text '\(text)' to clipboard")
            UIPasteboard.general.string = text
            toastMessageVM.showSuccess("Copied to clipboard")
        }
    }
    
    private func showLoading(_ key: String) {
        var newState = loadingState.mapValues({ _ in false })
        newState[key] = true
        loadingState = newState
    }
    
    private func hideLoading(_ key: String) {
        let newState = loadingState.mapValues({ _ in false })
        loadingState = newState
    }
    
    private func isFetching() -> Bool {
        return loadingState.values.contains(true)
    }
    
    private var isLoadingRewrite: Bool {
        return loadingState["rewrite"] ?? false
    }
    
    private var isDisableRewriteButton: Bool {
        if isEmptyConversationHistory() {
            return true
        }
        
        if isFetching(){
            return true
        }
        
        return isFirstConversation
    }
    
    private var isDisableCopyButton: Bool {
        if keyboardVM.inputText.isEmpty {
            return true
        }
        if sharedDataVM.translatedText.isEmpty {
            return true
        }
        return isFetching()
    }
    
    
    private var isLoadingGoBack: Bool {
        return loadingState[ConversationType.back.rawValue] ?? false
    }
    
    private var isDisableGoBackButton: Bool {
        if isFetching(){
            return true
        }
       return !hasPrevConversation
    }
    
    private var isLoadingForward: Bool {
        return loadingState[ConversationType.forward.rawValue] ?? false
    }
    
    private var isDisableForwardButton: Bool {
        if isFetching(){
            return true
        }
       return !hasNextConversation
    }
    
    private var rewriteButton: some View {
        QuickTaskButton("revert_ico"){
            Task {
                await onRewrite()
            }
        }.iconSize(width: 20.56, height: 18.91)
            .loading(isLoadingRewrite)
            .disabled(isDisableRewriteButton)
    }
    
    private var goBackButton: some View {
        QuickTaskButton("go_back_ico"){
            Task {
                await getConversation(for: .back)
            }
        }.iconSize(width: 14.41, height: 18.91)
            .loading(isLoadingGoBack)
            .disabled(isDisableGoBackButton)
    }
    
    private var forwardButton: some View {
        QuickTaskButton("forward_ico"){
            Task {
                await getConversation(for:.forward)
            }
        }.iconSize(width: 14.41, height: 18.91)
            .loading(isLoadingForward)
            .disabled(isDisableForwardButton)
    }
    
    private var copyButton: some View {
        QuickTaskButton("copy_ico"){
            copyTextToClipboard()
        }.iconSize(width: 14.41, height: 18.91)
            .loading(false)
            .disabled(isDisableCopyButton)
    }
    
    var body: some View {
        HStack(spacing:15) {
            goBackButton
            rewriteButton
            forwardButton
            copyButton
        }
        .allowsHitTesting(!isFetching())
//        .onChangeCompact(of: sharedDataVM.inputText) { value in
//            keyboardVM.setInputText(value)
//        }
    }
}

#Preview {
    @Previewable var container = SonaAppContainer(container: DIContainer.shared)
    @Previewable @StateObject var toastMessageVM = DIContainer.shared.toastMessageVM
    @Previewable @StateObject var sonaVM = SonaViewModel(sonaApiService: DIContainer.shared.sonaAPIService,
                                                         loadingVM: DIContainer.shared.loadingVM)
    
    QuickTaskView()
        .environmentObject(sonaVM)
        .setupKeyboardVMEnvironmentObjectPreview("I am hero")
        .setupCommonEnvironmentObjects(container)
        .setupEnvironmentObjectsPreview(container)
        .setupTokenApiPreview()
        .setupApiConfigPreview()
        .displayToastMessage(toastMessageVM)
        .onAppear {
            sonaVM.saveConversationHistory(ConversationHistoryModel(output: "I am an individual.", conversationId: "68bc2e045f7f2f6a38f79f81", promptOutputId: "68bc2e185f7f2f6a38f79f90", isFirst: true))
        }
}
