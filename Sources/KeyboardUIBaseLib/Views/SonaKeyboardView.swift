//
//  SonaKeyboardView.swift
//  BaseKeyboard
//
//  Created by Thien Tran-Quan on 15/8/25.
//

import SwiftUI

import Alamofire

struct SonaKeyboardView: View {
    @State private var showSupportedLanguages = false
    @State private var showDeleteConfirmation = false
    
    private let sonaApiService = SonaApiService()
    @StateObject private var sonaVM = SonaVM()
    
    private var textEditorButton: some View {
        WIconButton("text_editor_ico") {
            Task { @MainActor in
                do {
                    try await sonaVM.rewriteText(input: "Hello I im Binhdadads", tone: "Neutral ", persona: "Neutral")
                }catch {
                    
                }
            }
        }
        .buttonStyle(.contained)
        .backgroundColor(Color(hex: "#F6F5F4"))
        .foregroundColor(.black)
        .buttonSize(width: 45, height: 45)
        .iconSize(width: 15.76, height: 18.91)
        .cornerRadius(16)
        //.disabled()
        
        
    }
    
    private var translationButton: some View {
        WIconButton("translation_ico") {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showSupportedLanguages = true
            }
        }
        .buttonStyle(.contained)
        .backgroundColor(Color(hex: "#F6F5F4"))
        .foregroundColor(.black)
        .buttonSize(width: 45, height: 45)
        .iconSize(width: 25.22, height: 20)
        .cornerRadius(16)
        .disabled()
    }
    
    private var revertButton: some View {
        WIconButton("revert_ico") {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showDeleteConfirmation = true
            }
        }
        .buttonStyle(.contained)
        .backgroundColor(Color(hex: "#F6F5F4"))
        .foregroundColor(.black)
        .buttonSize(width: 45, height: 45)
        .iconSize(width: 20.56, height: 18.91)
        .cornerRadius(16)
        .disabled()
    }
    
    private var goBackButton: some View {
        WIconButton("go_back_ico")
            .buttonStyle(.contained)
            .backgroundColor(Color(hex: "#F6F5F4"))
            .foregroundColor(.black)
            .buttonSize(width: 45, height: 45)
            .iconSize(width: 14.41, height: 18.91)
            .cornerRadius(16)
            .disabled()
    }
    
    private var forwardButton: some View {
        WIconButton("forward_ico")
            .buttonStyle(.contained)
            .backgroundColor(Color(hex: "#F6F5F4"))
            .foregroundColor(.black)
            .buttonSize(width: 45, height: 45)
            .iconSize(width: 14.41, height: 18.91)
            .cornerRadius(16)
            .disabled()
    }
    
    private var suggestionInput: some View {
        ToneInput("Add custom tone...", text: .constant("")) {
            print("Add tapped")
        }.padding(.horizontal, 16)
    }
    
    private var quickTasksSection: some View {
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
    
    
    var body: some View {
        ZStack {
            // Main content
            VStack {
                quickTasksSection
                //suggestionInput
                WVSpacer(43)
                TonesView()
            }
            
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
    }
}

#Preview {
    SonaKeyboardView()
        .keyboardFramePreview()
}
