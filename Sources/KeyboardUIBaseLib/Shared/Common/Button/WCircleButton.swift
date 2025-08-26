//
//  WCircleButton.swift
//  BaseKeyboard
//
//  Created by Thien Tran-Quan on 16/8/25.
//

import SwiftUI

// MARK: - Circular Button Component using WIconButton
struct WCircleButton: View {
    // MARK: - Properties
    private var _iconButton: WIconButton
    
    // MARK: - Initializer
    init(
        _ iconName: String,
        size: CGFloat = 50,
        iconSize: CGFloat? = nil,
        style: WIconButtonStyle = .contained,
        backgroundColor: Color = Color(hex: "#007AFF"),
        foregroundColor: Color = .white,
        isActive: Bool = false,
        action: @escaping () -> Void = {}
    ) {
        let effectiveIconSize = iconSize ?? (size * 0.4)
        
        self._iconButton = WIconButton(
            iconName,
            style: style,
            size: CGSize(width: size, height: size),
            iconSize: CGSize(width: effectiveIconSize, height: effectiveIconSize),
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            cornerRadius: size / 2, // Make it circular
            isActive: isActive,
            action: action
        )
    }
    
    // MARK: - Body
    var body: some View {
        _iconButton
    }
}

// MARK: - Chain Modifier Extensions
extension WCircleButton {
    // Size modifiers
    func size(_ size: CGFloat) -> WCircleButton {
        var copy = self
        copy._iconButton = copy._iconButton
            .buttonSize(CGSize(width: size, height: size))
            .cornerRadius(size / 2)
        return copy
    }
    
    func iconSize(_ iconSize: CGFloat) -> WCircleButton {
        var copy = self
        copy._iconButton = copy._iconButton
            .iconSize(CGSize(width: iconSize, height: iconSize))
        return copy
    }
    
    // Style modifiers
    func style(_ style: WIconButtonStyle) -> WCircleButton {
        var copy = self
        copy._iconButton = copy._iconButton.buttonStyle(style)
        return copy
    }
    
    func backgroundColor(_ color: Color) -> WCircleButton {
        var copy = self
        copy._iconButton = copy._iconButton.backgroundColor(color)
        return copy
    }
    
    func foregroundColor(_ color: Color) -> WCircleButton {
        var copy = self
        copy._iconButton = copy._iconButton.foregroundColor(color)
        return copy
    }
    
    // State modifiers
    func active(_ isActive: Bool) -> WCircleButton {
        var copy = self
        copy._iconButton = copy._iconButton.active(isActive)
        return copy
    }
    
    // Quick style presets
    func outlined(color: Color = .blue) -> WCircleButton {
        var copy = self
        copy._iconButton = copy._iconButton.outlined(color: color)
        return copy
    }
    
    func contained(backgroundColor: Color = .blue, foregroundColor: Color = .white) -> WCircleButton {
        var copy = self
        copy._iconButton = copy._iconButton.contained(backgroundColor: backgroundColor, foregroundColor: foregroundColor)
        return copy
    }
    
    func minimal(color: Color = .primary) -> WCircleButton {
        var copy = self
        copy._iconButton = copy._iconButton.minimal(color: color)
        return copy
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 30) {
            // Basic Circle Buttons
            VStack(spacing: 16) {
                Text("WCircleButton Examples")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    HStack(spacing: 15) {
                        // Default contained circle button
                        WCircleButton("delete_ico")
                            .size(50)
                        
                        // Outlined circle button
                        WCircleButton("emoji_ico")
                            .style(.outlined)
                            .size(50)
                            .outlined(color: .blue)
                        
                        // Minimal circle button
                        WCircleButton("enter_ico")
                            .style(.minimal)
                            .size(50)
                            .minimal(color: .red)
                        
                        // Active state
                        WCircleButton("upper_case_ico")
                            .size(50)
                            .active(true)
                    }
                    
                    Text("Contained • Outlined • Minimal • Active")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Size Variations
            VStack(spacing: 16) {
                Text("Size Variations")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    HStack(spacing: 15) {
                        WCircleButton("delete_ico")
                            .size(36)
                        WCircleButton("emoji_ico")
                            .size(50)
                        WCircleButton("enter_ico")
                            .size(64)
                    }
                    
                    Text("Small (36) • Medium (50) • Large (64)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Color Variations
            VStack(spacing: 16) {
                Text("Color Variations")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    HStack(spacing: 15) {
                        WCircleButton("delete_ico")
                            .contained(backgroundColor: .red, foregroundColor: .white)
                        
                        WCircleButton("emoji_ico")
                            .contained(backgroundColor: .green, foregroundColor: .white)
                        
                        WCircleButton("enter_ico")
                            .contained(backgroundColor: .orange, foregroundColor: .white)
                        
                        WCircleButton("upper_case_ico")
                            .contained(backgroundColor: .purple, foregroundColor: .white)
                    }
                    
                    Text("Custom colors")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}
