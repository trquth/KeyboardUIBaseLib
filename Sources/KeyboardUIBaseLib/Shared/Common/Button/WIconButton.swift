//
//  WIconButton.swift
//  BaseKeyboard
//
//  Created by Thien Tran-Quan on 15/8/25.
//

import SwiftUI

// MARK: - Button Style Types
enum WIconButtonStyle {
    case outlined                // Outlined style
    case contained               // Contained style with solid background
    case minimal                 // Just icon, no background
}

// MARK: - Unified WIconButton Component
struct WIconButton: View {
    // MARK: - Properties (WIconButton style)
    private var _iconName: String
    private var _style: WIconButtonStyle
    private var _size: CGSize
    private var _iconSize: CGSize?
    private var _backgroundColor: Color
    private var _foregroundColor: Color
    private var _cornerRadius: CGFloat?
    private var _isActive: Bool
    private var _isEnabled: Bool
    private var _action: () -> Void
    
    // MARK: - Initializer (WIconButton style)
    init(
        _ iconName: String,
        style: WIconButtonStyle = .outlined,
        size: CGSize = CGSize(width: 46.5, height: 45),
        iconSize: CGSize? = nil,
        backgroundColor: Color = Color(hex: "#E8E8E8"),
        foregroundColor: Color = .primary,
        cornerRadius: CGFloat? = nil,
        isActive: Bool = false,
        isEnabled: Bool = true,
        action: @escaping () -> Void = {}
    ) {
        self._iconName = iconName
        self._style = style
        self._size = size
        self._iconSize = iconSize
        self._backgroundColor = backgroundColor
        self._foregroundColor = foregroundColor
        self._cornerRadius = cornerRadius
        self._isActive = isActive
        self._isEnabled = isEnabled
        self._action = action
    }
    
    // MARK: - Computed Properties (WIconButton style)
    private var effectiveBackgroundColor: Color {
        if !_isEnabled {
            return Color(hex: "#F6F5F4")
        }
        
        if _isActive {
            return Color(hex: "#007AFF")
        }
        
        switch _style {
        case .minimal:
            return .clear
        case .outlined:
            return .clear
        case .contained:
            return _backgroundColor != Color(hex: "#E8E8E8") ? _backgroundColor : Color(hex: "#007AFF")
        }
    }
    
    private var effectiveForegroundColor: Color {
        if !_isEnabled {
            return .black.opacity(0.3)
        }
        
        if _isActive {
            return .white
        }
        
        switch _style {
        case .contained:
            return _foregroundColor != .primary ? _foregroundColor : .white
        case .outlined:
            return _foregroundColor != .primary ? _foregroundColor : Color(hex: "#007AFF")
        case .minimal:
            return _foregroundColor
        }
    }
    
    private var effectiveIconSize: CGSize {
        if let iconSize = _iconSize {
            return iconSize
        }
        
        // Auto-calculate icon size based on button size
        let iconWidth = min(_size.width * 0.4, _size.height * 0.4)
        return CGSize(width: iconWidth, height: iconWidth)
    }
    
    private var effectiveCornerRadius: CGFloat {
        if let cornerRadius = _cornerRadius {
            return cornerRadius
        }
        
        switch _style {
        case .outlined:
            return 8.0
        case .contained:
            return 8.0
        case .minimal:
            return 0
        }
    }
    
    // MARK: - Icon View Builder (WIconButton style)
    @ViewBuilder
    private var iconView: some View {
        WImage(_iconName)
            .renderingMode(.template)
            .foregroundColor(effectiveForegroundColor)
            .frame(width: effectiveIconSize.width, height: effectiveIconSize.height)
    }
    
    // MARK: - Background View Builder (WIconButton style)
    @ViewBuilder
    private var backgroundView: some View {
        switch _style {
        case .contained:
            RoundedRectangle(cornerRadius: effectiveCornerRadius)
                .fill(effectiveBackgroundColor)
            
        case .outlined:
            RoundedRectangle(cornerRadius: effectiveCornerRadius)
                .stroke(effectiveForegroundColor, lineWidth: 1.5)
                .background(
                    RoundedRectangle(cornerRadius: effectiveCornerRadius)
                        .fill(effectiveBackgroundColor)
                )
            
        case .minimal:
            Color.clear
        }
    }
    
    // MARK: - Body
    var body: some View {
        Button(action: _action) {
            iconView
        }
        .frame(width: _size.width, height: _size.height)
        .background(backgroundView)
        .scaleEffect(_isActive ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: _isActive)
        .disabled(!_isEnabled)
        .allowsHitTesting(_isEnabled)
    }
}

// MARK: - Chain Modifier Extensions
extension WIconButton {
    // Style modifiers (WIconButton-style approach)
    func buttonStyle(_ style: WIconButtonStyle) -> WIconButton {
        var copy = self
        copy._style = style
        return copy
    }
    
    func buttonSize(_ size: CGSize) -> WIconButton {
        var copy = self
        copy._size = size
        return copy
    }
    
    func buttonSize(width: CGFloat, height: CGFloat) -> WIconButton {
        buttonSize(CGSize(width: width, height: height))
    }
    
    func iconSize(_ iconSize: CGSize?) -> WIconButton {
        var copy = self
        copy._iconSize = iconSize
        return copy
    }
    
    func iconSize(width: CGFloat, height: CGFloat) -> WIconButton {
        iconSize(CGSize(width: width, height: height))
    }
    
    func backgroundColor(_ color: Color) -> WIconButton {
        var copy = self
        copy._backgroundColor = color
        return copy
    }
    
    func foregroundColor(_ color: Color) -> WIconButton {
        var copy = self
        copy._foregroundColor = color
        return copy
    }
    
    func cornerRadius(_ radius: CGFloat) -> WIconButton {
        var copy = self
        copy._cornerRadius = radius
        return copy
    }
    
    func active(_ isActive: Bool) -> WIconButton {
        var copy = self
        copy._isActive = isActive
        return copy
    }
    
    func enabled(_ isEnabled: Bool) -> WIconButton {
        var copy = self
        copy._isEnabled = isEnabled
        if !isEnabled {
            copy._backgroundColor = Color(hex: "#F6F5F4")
            copy._foregroundColor = .black.opacity(0.3)
        }
        return copy
    }
    
    // MARK: - Enhanced Modifiers (WIconButton style)
    
    // Quick style presets
    func outlined(color: Color = .blue) -> WIconButton {
        var copy = self
        copy._style = .outlined
        copy._backgroundColor = .clear
        copy._foregroundColor = color
        return copy
    }
    
    func contained(backgroundColor: Color = .blue, foregroundColor: Color = .white) -> WIconButton {
        var copy = self
        copy._backgroundColor = backgroundColor
        copy._foregroundColor = foregroundColor
        return copy
    }
    
    func minimal(color: Color = .primary) -> WIconButton {
        var copy = self
        copy._style = .minimal
        copy._backgroundColor = .clear
        copy._foregroundColor = color
        return copy
    }
}

// MARK: - Factory Methods with Chain Support
extension WIconButton {
    // Asset-based factory
    static func icon(_ name: String) -> WIconButton {
        WIconButton(name)
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 30) {
            // Chain Modifier Examples
            VStack(spacing: 16) {
                Text("WIconButton Examples")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    HStack(spacing: 15) {
                        // Outlined asset button
                        WIconButton("delete_ico")
                            .buttonStyle(.outlined)
                            .contained(backgroundColor: .blue, foregroundColor: .white)
                            .buttonSize(width: 44, height: 44)
                            .iconSize(width: 20, height: 20)
                        
                        // Contained asset button
                        WIconButton("emoji_ico")
                            .buttonStyle(.contained)
                            .contained(backgroundColor: .green, foregroundColor: .white)
                            .buttonSize(width: 56, height: 56)
                            .iconSize(width: 24, height: 24)
                        
                        // Minimal asset button
                        WIconButton("enter_ico")
                            .buttonStyle(.minimal)
                            .contained(backgroundColor: .red, foregroundColor: .white)
                            .buttonSize(width: 44, height: 44)
                            .iconSize(width: 20, height: 20)
                    }
                    
                    Text("Asset buttons with different styles")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Style Examples
            VStack(spacing: 16) {
                Text("Style Variations")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    HStack(spacing: 15) {
                        WIconButton("emoji_ico")
                            .buttonStyle(.outlined)
                            .foregroundColor(.red)
                        
                        WIconButton("emoji_ico")
                            .buttonStyle(.contained)
                            .contained(backgroundColor: .blue, foregroundColor: .white)
                        
                        WIconButton("emoji_ico")
                            .buttonStyle(.minimal)
                            .foregroundColor(.red)
                    }
                    
                    Text("Outlined • Contained • Minimal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Keyboard Style Examples
            VStack(spacing: 16) {
                Text("Keyboard Buttons")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        WIconButton("delete_ico")
                            .buttonStyle(.outlined)
                            .backgroundColor(Color(hex: "#E8E8E8"))
                            .foregroundColor(.black)
                            .buttonSize(width: 46.5, height: 45)
                            .iconSize(width: 17, height: 15)
                        
                        WIconButton("emoji_ico")
                            .buttonStyle(.outlined)
                            .backgroundColor(Color(hex: "#E8E8E8"))
                            .foregroundColor(.black)
                            .buttonSize(width: 46.5, height: 45)
                            .iconSize(width: 17, height: 15)
                            .active(true)
                        
                        WIconButton("enter_ico")
                            .buttonStyle(.contained)
                            .backgroundColor(Color(hex: "#E8E8E8"))
                            .foregroundColor(.black)
                            .buttonSize(width: 46.5, height: 45)
                            .iconSize(width: 17, height: 15)
                        
                        WIconButton("upper_case_ico"){
                            print("Upper case pressed")
                        }
                        .buttonStyle(.outlined)
                        .backgroundColor(Color(hex: "#E8E8E8"))
                        .foregroundColor(.black)
                        .buttonSize(width: 46.5, height: 45)
                        .iconSize(width: 17, height: 15)
                        .enabled(false)
                    }
                    
                    Text("Keyboard-style asset buttons")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}
