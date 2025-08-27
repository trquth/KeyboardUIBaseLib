//
//  QuickTaskView.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 26/8/25.
//

import SwiftUI

struct QuickTaskView: View {
    @EnvironmentObject private var sonaVM: SonaViewModel
    @EnvironmentObject private var loadingVM: LoadingViewModel

    private var textEditorButton: some View {
        QuickTaskButton("text_editor_ico"){
            Task { @MainActor in
                do {
                    let data = RewriteRequestParam(message: "Hello I im Binhdadads", tone: "Neutral", persona: "Neutral")
                    try await sonaVM.rewriteText(data)
                }catch {
                    print("Error rewriting text: \(error)")
                }
            }
        }.iconSize(width: 15.76, height: 18.91)
            .loading(loadingVM.isLoading)
            .disabled(loadingVM.isLoading)
    }
    
    private var translationButton: some View {
        QuickTaskButton("translation_ico"){
            
        }.iconSize(width: 25.22, height: 20)
            .loading(false)
            .disabled(true)
    }
    
    private var revertButton: some View {
        QuickTaskButton("revert_ico"){
            
        }.iconSize(width: 20.56, height: 18.91)
            .loading(false)
            .disabled(true)
    }
    
    private var goBackButton: some View {
        QuickTaskButton("go_back_ico"){
            
        }.iconSize(width: 14.41, height: 18.91)
            .loading(false)
            .disabled(true)
    }
    
    private var forwardButton: some View {
        QuickTaskButton("forward_ico"){
            print("Forward action")
        }.iconSize(width: 14.41, height: 18.91)
            .loading(false)
            .disabled(false)
    }
    
    
    var body: some View {
        VStack(spacing: 0) {                
            WText("QUICKTASKS")
                .customFont(.interSemiBold, size: 10.5)
            WVSpacer(10)
            HStack(spacing:18) {
                textEditorButton
                translationButton
                revertButton
                goBackButton
                forwardButton
            }
        }
    }
}

#Preview {
    @Previewable @StateObject var container = SonaAppContainer(container: DIContainer.shared)
    QuickTaskView()
        .environmentObject(container.sonaVM)
        .environmentObject(container.loadingVM)
}
