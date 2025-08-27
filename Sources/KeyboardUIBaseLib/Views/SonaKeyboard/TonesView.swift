//
//  PersonaSelectionView.swift
//  BaseKeyboard
//
//  Created by Thien Tran-Quan on 16/8/25.
//

import SwiftUI

struct TonesView: View {
    @EnvironmentObject private var sonaVM: SonaViewModel

    private func isSelectedTone(_ tone: String) -> Bool {
        return sonaVM.selectedTone == tone
    }
    
    private func isSelectedPersona(_ persona: String) -> Bool {
        return sonaVM.selectedPersona == persona
    }
    
    private let linearGradientColors = [Color.black.opacity(0),
                                        Color.black.opacity(0.3),
                                        Color.black.opacity(0.6),
                                        Color.black.opacity(0.7),
                                        Color.red]
    
    private var leftBlurView: some View {
        HStack(spacing:0){
            Rectangle()
                .fill(.thinMaterial)
                .mask {
                    LinearGradient(colors:linearGradientColors,
                                   startPoint: .trailing,
                                   endPoint: .leading)
                    
                } .frame(width: 30)
            Spacer()
        }
    }
    
    private var rightBlurView: some View {
        HStack(spacing:0){
            Spacer()
            Rectangle()
                .fill(.thinMaterial)
                .mask {
                    LinearGradient(colors:linearGradientColors,
                                   startPoint: .leading,
                                   endPoint: .trailing)
                    
                } .frame(width: 30)
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing:5) {
                        ForEach(SONA_TONES, id: \.self) { option in
                            ChipView(option){
                                sonaVM.selectTone(option)
                            }.isSelected(isSelectedTone(option))
                                .small()
                        }
                    }
                    .padding(.horizontal, 25)
                    .frame(maxHeight:.infinity,alignment:.top)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing:5) {
                        ForEach(SONA_PERSONAS , id: \.self) { option in
                            ChipView(option){
                                sonaVM.selectPersona(option)
                            }.isSelected(isSelectedPersona(option))
                        }
                    }
                    .padding(.horizontal, 25)
                    .frame(maxHeight:.infinity,alignment:.bottom)
                }
            }
            leftBlurView
            rightBlurView
        }.frame(height: 95)
    }
}

#Preview {
    @Previewable @StateObject var container = SonaAppContainer(container: DIContainer.shared)
    TonesView()
        .environmentObject(container.sonaVM)
        .environmentObject(container.loadingVM)
}
