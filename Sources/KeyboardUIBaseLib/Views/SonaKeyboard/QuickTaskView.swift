//
//  QuickTaskView.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 26/8/25.
//

import SwiftUI

struct QuickTaskView: View {
    private var textEditorButton: some View {
        QuickTaskButton("text_editor_ico"){
            
        }.iconSize(width: 15.76, height: 18.91)
            .loading(false)
            .disabled(true)
    }
    
    private var translationButton: some View {
        QuickTaskButton("translation_ico"){
            
        }.iconSize(width: 25.22, height: 20)
            .loading(false)
            .disabled(true)
        
//        WIconButton("translation_ico") {
//            //            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
//            //                showSupportedLanguages = true
//            //            }
//        }
//        .buttonStyle(.contained)
//        .backgroundColor(Color(hex: "#F6F5F4"))
//        .foregroundColor(.black)
//        .buttonSize(width: 45, height: 45)
//        .iconSize(width: 25.22, height: 20)
//        .cornerRadius(16)
    }
    
    private var revertButton: some View {
        QuickTaskButton("revert_ico"){
            
        }.iconSize(width: 20.56, height: 18.91)
            .loading(false)
            .disabled(true)
//        WIconButton("revert_ico") {
//            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
//                //showDeleteConfirmation = true
//            }
//        }
//        .buttonStyle(.contained)
//        .backgroundColor(Color(hex: "#F6F5F4"))
//        .foregroundColor(.black)
//        .buttonSize(width: 45, height: 45)
//        .iconSize(width: 20.56, height: 18.91)
//        .cornerRadius(16)
    }
    
    private var goBackButton: some View {
        QuickTaskButton("go_back_ico"){
            
        }.iconSize(width: 14.41, height: 18.91)
            .loading(false)
            .disabled(true)
//        WIconButton("go_back_ico")
//            .buttonStyle(.contained)
//            .backgroundColor(Color(hex: "#F6F5F4"))
//            .foregroundColor(.black)
//            .buttonSize(width: 45, height: 45)
//            .iconSize(width: 14.41, height: 18.91)
//            .cornerRadius(16)
    }
    
    private var forwardButton: some View {
        QuickTaskButton("forward_ico"){
            print("Forward action")
        }.iconSize(width: 14.41, height: 18.91)
            .loading(false)
            .disabled(false)
//        WIconButton("forward_ico")
//            .buttonStyle(.contained)
//            .backgroundColor(Color(hex: "#F6F5F4"))
//            .foregroundColor(.black)
//            .buttonSize(width: 45, height: 45)
//            .iconSize(width: 14.41, height: 18.91)
//            .cornerRadius(16)
//            .enabled(false)
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
    QuickTaskView()
}
