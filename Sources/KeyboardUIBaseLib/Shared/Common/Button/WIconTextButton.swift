//
//  WIconTextButton.swift
//  BaseKeyboard
//
//  Created by Thien Tran-Quan on 17/8/25.
//

import SwiftUI

// MARK: - Icon Text Button Style Types
enum WIconTextButtonStyle {
    case outlined                // Outlined style
    case contained               // Contained style with solid background
    case minimal                 // Just icon and text, no background
}

// MARK: - Icon Position Types
enum WIconPosition {
    case leading                 // Icon on the left
    case trailing                // Icon on the right
}

// MARK: - Unified WIconTextButton Component
struct WIconTextButton: View {
    // MARK: - Properties
    private var _iconName: String
    private var _text: String
    private var _iconPosition: WIconPosition
    private var _style: WIconTextButtonStyle
    private var _size: CGSize
    private var _iconSize: CGSize?
    private var _spacing: CGFloat
    private var _font: Font
    private var _backgroundColor: Color
    private var _foregroundColor: Color
    private var _cornerRadius: CGFloat?
    private var _isActive: Bool
    private var _action: () -> Void
    
    // MARK: - Initializer
    init(
        _ iconName: String,
        text: String,
        iconPosition: WIconPosition = .leading,
        style: WIconTextButtonStyle = .outlined,
        size: CGSize = CGSize(width: 120, height: 45),
        iconSize: CGSize? = nil,
        spacing: CGFloat = 8,
        font: Font = .custom(FontName.interRegular, size: 16),
        backgroundColor: Color = Color(hex: "#E8E8E8"),
        foregroundColor: Color = .primary,
        cornerRadius: CGFloat? = nil,
        isActive: Bool = false,
        action: @escaping () -> Void = {}
    ) {
        self._iconName = iconName
        self._text = text
        self._iconPosition = iconPosition
        self._style = style
        self._size = size
        self._iconSize = iconSize
        self._spacing = spacing
        self._font = font
        self._backgroundColor = backgroundColor
        self._foregroundColor = foregroundColor
        self._cornerRadius = cornerRadius
        self._isActive = isActive
        self._action = action
    }
    
    // MARK: - Computed Properties
    private var effectiveBackgroundColor: Color {
        if _isActive {
            return Color(hex: "#007AFF")
        }
        
        switch _style {
        case .minimal:
            return .clear
        case .outlined:
            return .clear
        case .contained:
            return _backgroundColor
        }
    }
    
    private var effectiveForegroundColor: Color {
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
        
        // Auto-calculate icon size based on button height
        let iconHeight = min(_size.height * 0.4, 20)
        return CGSize(width: iconHeight, height: iconHeight)
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
    
    // MARK: - Content View Builder
    @ViewBuilder
    private var contentView: some View {
        HStack(spacing: _spacing) {
            if _iconPosition == .leading {
                iconView
                textView
            } else {
                textView
                iconView
            }
        }
    }
    
    // MARK: - Icon View Builder
    @ViewBuilder
    private var iconView: some View {
        WImage(_iconName)
            .renderingMode(.template)
            .foregroundColor(effectiveForegroundColor)
            .frame(width: effectiveIconSize.width, height: effectiveIconSize.height)
    }
    
    // MARK: - Text View Builder
    @ViewBuilder
    private var textView: some View {
        WText(_text)
            .font(_font)
            .foregroundColor(effectiveForegroundColor)
    }
    
    // MARK: - Background View Builder
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
            contentView
        }
        .frame(
            width: _size.width == .infinity ? nil : _size.width,
            height: _size.height
        )
        .frame(maxWidth: _size.width == .infinity ? .infinity : nil)
        .background(backgroundView)
        .scaleEffect(_isActive ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: _isActive)
    }
}

// MARK: - Chain Modifier Extensions
extension WIconTextButton {
    // Style modifiers
    func buttonStyle(_ style: WIconTextButtonStyle) -> WIconTextButton {
        var copy = self
        copy._style = style
        return copy
    }
    
    func iconPosition(_ position: WIconPosition) -> WIconTextButton {
        var copy = self
        copy._iconPosition = position
        return copy
    }
    
    func buttonSize(_ size: CGSize) -> WIconTextButton {
        var copy = self
        copy._size = size
        return copy
    }
    
    func buttonSize(width: CGFloat, height: CGFloat) -> WIconTextButton {
        buttonSize(CGSize(width: width, height: height))
    }
    
    func fullWidth(height: CGFloat = 45) -> WIconTextButton {
        var copy = self
        copy._size = CGSize(width: .infinity, height: height)
        return copy
    }
    
    func iconSize(_ iconSize: CGSize?) -> WIconTextButton {
        var copy = self
        copy._iconSize = iconSize
        return copy
    }
    
    func iconSize(width: CGFloat, height: CGFloat) -> WIconTextButton {
        iconSize(CGSize(width: width, height: height))
    }
    
    func spacing(_ spacing: CGFloat) -> WIconTextButton {
        var copy = self
        copy._spacing = spacing
        return copy
    }
    
    func font(_ font: Font) -> WIconTextButton {
        var copy = self
        copy._font = font
        return copy
    }
    
    func customFont(_ fontName: FontName, size: CGFloat) -> WIconTextButton {
        var copy = self
        copy._font = .custom(fontName, size: size)
        return copy
    }
    
    func backgroundColor(_ color: Color) -> WIconTextButton {
        var copy = self
        copy._backgroundColor = color
        return copy
    }
    
    func foregroundColor(_ color: Color) -> WIconTextButton {
        var copy = self
        copy._foregroundColor = color
        return copy
    }
    
    func cornerRadius(_ radius: CGFloat) -> WIconTextButton {
        var copy = self
        copy._cornerRadius = radius
        return copy
    }
    
    func active(_ isActive: Bool) -> WIconTextButton {
        var copy = self
        copy._isActive = isActive
        return copy
    }
    
    // MARK: - Enhanced Modifiers
    
    // Quick style presets
    func outlined(color: Color = .blue) -> WIconTextButton {
        var copy = self
        copy._style = .outlined
        copy._backgroundColor = .clear
        copy._foregroundColor = color
        return copy
    }
    
    func contained(backgroundColor: Color = .blue, foregroundColor: Color = .white) -> WIconTextButton {
        var copy = self
        copy._style = .contained
        copy._backgroundColor = backgroundColor
        copy._foregroundColor = foregroundColor
        return copy
    }
    
    func minimal(color: Color = .primary) -> WIconTextButton {
        var copy = self
        copy._style = .minimal
        copy._backgroundColor = .clear
        copy._foregroundColor = color
        return copy
    }
    
    // State modifiers
    func disabled() -> WIconTextButton {
        var copy = self
        copy._backgroundColor = Color.gray.opacity(0.3)
        copy._foregroundColor = .gray
        return copy
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 30) {
            // Basic Examples
            VStack(spacing: 16) {
                Text("WIconTextButton Examples")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    HStack(spacing: 15) {
                        // Leading icon
                        WIconTextButton("delete_ico", text: "Delete")
                            .buttonStyle(.outlined)
                            .buttonSize(width: 120, height: 40)
                        
                        // Trailing icon
                        WIconTextButton("forward_ico", text: "Next")
                            .iconPosition(.trailing)
                            .buttonStyle(.contained)
                            .buttonSize(width: 100, height: 40)
                    }
                    
                    Text("Leading • Trailing positions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Style Variations
            VStack(spacing: 16) {
                Text("Style Variations")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    VStack(spacing: 12) {
                        WIconTextButton("translation_ico", text: "Translate")
                            .buttonStyle(.outlined)
                            .outlined(color: .blue)
                            .buttonSize(width: 140, height: 40)
                        
                        WIconTextButton("text_editor_ico", text: "Edit")
                            .buttonStyle(.contained)
                            .contained(backgroundColor: .green, foregroundColor: .white)
                            .buttonSize(width: 140, height: 40)
                        
                        WIconTextButton("revert_ico", text: "Undo")
                            .buttonStyle(.minimal)
                            .minimal(color: .red)
                            .buttonSize(width: 140, height: 40)
                    }
                    
                    Text("Outlined • Contained • Minimal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}
