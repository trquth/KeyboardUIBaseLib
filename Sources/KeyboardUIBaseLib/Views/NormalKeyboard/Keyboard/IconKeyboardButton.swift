//
//  IconKeyboardButton.swift
//  BaseKeyboard
//
//  Created by Thien Tran-Quan on 15/8/25.
//

import SwiftUI

struct IconKeyboardButton: View {
    let assetName: String
    let width: CGFloat
    let height: CGFloat
    let iconSize: CGSize
    let foregroundColor: Color
    let backgroundColor: Color?
    let isActive: Bool
    let action: () -> Void
    
    init(
        assetName: String,
        width: CGFloat = 46.5,
        height: CGFloat = 45,
        iconSize: CGSize = CGSize(width: 17, height: 15),
        foregroundColor: Color = .black,
        backgroundColor: Color? = nil,
        isActive: Bool = false,
        action: @escaping () -> Void = {}
    ) {
        self.assetName = assetName
        self.width = width
        self.height = height
        self.iconSize = iconSize
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.isActive = isActive
        self.action = action
    }
    
    private var buttonStyle: WIconButtonStyle {
        return backgroundColor == nil ? .minimal : .contained
    }
    
    private var buttonBackgroundColor: Color {
        return backgroundColor ?? .clear
    }
        
    var body: some View {
        WIconButton(assetName, action: action)
            .buttonStyle(.contained)
            .buttonSize(width: width, height: height)
            .iconSize(iconSize)
            .foregroundColor(foregroundColor)
            .backgroundColor(buttonBackgroundColor)
            .cornerRadius(5.7)
            .active(isActive)
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("IconKeyboardButton Examples")
            .font(.headline)
        
        HStack(spacing: 15) {
            // Default button
            IconKeyboardButton(
                assetName: "delete_ico"
            ) {
                print("Delete pressed")
            }
            
            // Custom styled button
            IconKeyboardButton(
                assetName: "emoji_ico",
                width: 50,
                height: 50,
                iconSize: CGSize(width: 20, height: 20),
                foregroundColor: .blue
            ) {
                print("Emoji pressed")
            }
            
            // Active state button
            IconKeyboardButton(
                assetName: "enter_ico",
                foregroundColor: .red
            ) {
                print("Enter pressed")
            }
        }
        
        HStack(spacing: 15) {
            // More examples
            IconKeyboardButton(
                assetName: "upper_case_ico",
                width: 60,
                height: 40,
                foregroundColor: .blue
            ) {
                print("Upper case pressed")
            }
            
            IconKeyboardButton(
                assetName: "delete_ico",
                foregroundColor: .green,
                backgroundColor: Color(hex: "#E8E8E8")
            ) {
                print("Green delete pressed")
            }
        }
    }
    .padding()
}
