//
//  TextKeyboardButton.swift
//  BaseKeyboard
//
//  Created by Thien Tran-Quan on 15/8/25.
//

import SwiftUI

struct TextKeyboardButton: View {
    let text: String
    let width: CGFloat
    let height: CGFloat
    let titleFontSize: CGFloat
    let buttonStyle: WTextButtonStyle
    let backgroundColor: Color
    let foregroundColor: Color
    let isActive: Bool
    let action: () -> Void
    
    init(
        text: String = "ABC",
        width: CGFloat = 60,
        height: CGFloat = 45,
        titleFontSize: CGFloat = 22,
        buttonStyle: WTextButtonStyle = .contained,
        backgroundColor: Color = Color(hex: "#E8E8E8"),
        foregroundColor: Color = .black,
        isActive: Bool = false,
        action: @escaping () -> Void = {}
    ) {
        self.text = text
        self.width = width
        self.height = height
        self.titleFontSize = titleFontSize
        self.buttonStyle = buttonStyle
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.isActive = isActive
        self.action = action
    }
    
    var body: some View {
        WTextButton(text, action: action)
            .buttonStyle(buttonStyle)
            .buttonSize(width: width, height: height)
            .backgroundColor(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(5.7)
            .active(isActive)
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("TextKeyboardButton Examples")
            .font(.headline)
        
        HStack(spacing: 15) {
            // Default button
            TextKeyboardButton(
                text: "ABC"
            ) {
                print("ABC pressed")
            }
            
            // Custom styled button
            TextKeyboardButton(
                text: "A",
                width: 31.33,
                height: 50,
                titleFontSize: 20,
                buttonStyle: .contained,
                backgroundColor: Color(hex: "#007AFF"),
                foregroundColor: .black
            ) {
                print("123 pressed")
            }
            
            // Active state button
            TextKeyboardButton(
                text: "shift",
                buttonStyle: .minimal,
                backgroundColor: Color(hex: "#E8E8E8"),
                foregroundColor: .black,
                isActive: true
            ) {
                print("Shift pressed")
            }
        }
        
        HStack(spacing: 15) {
            // More examples
            TextKeyboardButton(
                text: "space",
                width: 120,
                height: 40,
                titleFontSize: 16,
                backgroundColor: Color(hex: "#F3E8FF"),
                foregroundColor: Color(hex: "#8B5CF6")
            ) {
                print("Space pressed")
            }
            
            TextKeyboardButton(
                text: "return",
                width: 80,
                height: 45,
                backgroundColor: Color.green,
                foregroundColor: .white
            ) {
                print("Return pressed")
            }
        }
    }
    .padding()
}
