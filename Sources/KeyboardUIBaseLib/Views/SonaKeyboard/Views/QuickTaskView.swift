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
        
    @State  private var conversationHistory: ConversationHistory? = nil
    @State private var loadingState: [String: Bool] = [:]
    
    private func onRewrite() async {
        do {
            showLoading("rewrite")
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
            
            saveTransactionHistory(data)
        
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
            if let history = conversationHistory {
                let conversationId = history.conversationId
                let promptOutputId = history.promptOutputId
                showLoading(type.rawValue)
                let data = ConversationRequestParam(conversationId: conversationId, promptOutputId: promptOutputId)
                
                let conversation = try await sonaVM.getConversation(for:type, data: data)
                print("Conversation: \(conversation)")
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
    
    private func saveTransactionHistory(_ data: Any){
        var history: ConversationHistory?
        // Save the transaction history
        if let rewriteData = data as? RewriteDataResponse {
           let conversation = rewriteData.conversation
            let conversationId = conversation.conversationID
            let promptOutputId = conversation.outputID
            
            history = ConversationHistory(conversationId: conversationId, promptOutputId: promptOutputId)
        }
       
        if let proofreadData = data as? ProofreadDataResponse {
            let conversation = proofreadData.conversation
            let conversationId = conversation.conversationID
            let promptOutputId = conversation.outputID
            
            history = ConversationHistory(conversationId: conversationId, promptOutputId: promptOutputId)
        }
        // You can store this history in a list or database as needed
        conversationHistory = history
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
        if keyboardVM.inputText.isEmpty {
            return true
        }
        return isFetching()
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
        if conversationHistory == nil {
            return true
        }
        return isFetching()
    }
    
    private var isLoadingForward: Bool {
        return loadingState[ConversationType.forward.rawValue] ?? false
    }
    
    private var isDisableForwardButton: Bool {
        if conversationHistory == nil {
            return true
        }
        return isFetching()
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

extension QuickTaskView {
    private struct ConversationHistory {
        let conversationId: String
        let promptOutputId: String
        
        init(conversationId: String, promptOutputId: String) {
            self.conversationId = conversationId
            self.promptOutputId = promptOutputId
        }
    }
}

#Preview {
    @Previewable var container = SonaAppContainer(container: DIContainer.shared)
    @Previewable @StateObject var toastMessageVM = DIContainer.shared.toastMessageVM
    
    QuickTaskView()
        .setupKeyboardVMEnvironmentObjectPreview("I am hero")
        .setupCommonEnvironmentObjects(container)
        .setupEnvironmentObjectsPreview(container)
        .setupTokenApiPreview()
        .setupApiConfigPreview()
        .displayToastMessage(toastMessageVM)
}
