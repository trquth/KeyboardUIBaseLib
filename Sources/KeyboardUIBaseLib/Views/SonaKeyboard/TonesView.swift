//
//  PersonaSelectionView.swift
//  BaseKeyboard
//
//  Created by Thien Tran-Quan on 16/8/25.
//

import SwiftUI

struct TonesView: View {
    
    // Persona options from the image
    private let personaOptions = [
        "Encouraging", "Neutral", "Confident", "Reflective", "Persona Work Colleague"
    ]
    
    private let personaOptions2 = [
        "Neutral",  "Reflective", "Persona Work Colleague", "Confident", "Encouraging", "Neutral"
    ]
    
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
                        ForEach(personaOptions, id: \.self) { option in
                            ChipView(
                                title: option,
                                isSelected: false,
                                size: .small
                            ) {
                            }
                        }
                    }
                    .padding(.horizontal, 25)
                    .frame(maxHeight:.infinity,alignment:.top)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing:5) {
                        ForEach(personaOptions2 , id: \.self) { option in
                            ChipView(
                                title: option,
                                isSelected: false
                            ) {
                            }
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
    TonesView()
}
