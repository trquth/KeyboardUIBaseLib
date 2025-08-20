//
//  WTextButton.swift
//  BaseKeyboard
//
//  Created by Thien Tran-Quan on 16/8/25.
//

import SwiftUI

// MARK: - Text Button Style Types
enum WTextButtonStyle {
    case outlined                // Outlined style
    case contained               // Contained style with solid background
    case minimal                 // Just text, no background
}

// MARK: - Unified WTextButton Component
struct WTextButton: View {
    // MARK: - Properties (WIconButton style)
    private var _text: String
    private var _style: WTextButtonStyle
    private var _size: CGSize
    private var _font: Font
    private var _backgroundColor: Color
    private var _foregroundColor: Color
    private var _cornerRadius: CGFloat?
    private var _isActive: Bool
    private var _horizontalPadding: CGFloat
    private var _verticalPadding: CGFloat
    private var _buttonHeight: CGFloat?
    private var _action: () -> Void
    
    // MARK: - Initializer (WIconButton style)
    init(
        _ text: String,
        style: WTextButtonStyle = .outlined,
        size: CGSize = CGSize(width: 100, height: 45),
        font: Font = .custom(FontName.interRegular, size: 16),
        backgroundColor: Color = Color(hex: "#007AFF"),
        foregroundColor: Color = .primary,
        cornerRadius: CGFloat? = nil,
        horizontalPadding: CGFloat = 0,
        verticalPadding: CGFloat = 0,
        isActive: Bool = false,
        buttonHeight: CGFloat? = nil,
        action: @escaping () -> Void = {}
    ) {
        self._text = text
        self._style = style
        self._size = size
        self._font = font
        self._backgroundColor = backgroundColor
        self._foregroundColor = foregroundColor
        self._cornerRadius = cornerRadius
        self._horizontalPadding = horizontalPadding
        self._verticalPadding = verticalPadding
        self._isActive = isActive
        self._buttonHeight = buttonHeight
        self._action = action
    }
    
    // MARK: - Computed Properties (WIconButton style)
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
    
    // MARK: - Text View Builder (WIconButton style)
    @ViewBuilder
    private var textView: some View {
        WText(_text)
            .font(_font)
            .foregroundColor(effectiveForegroundColor)
            .padding(.horizontal, _horizontalPadding)
            .padding(.vertical, _verticalPadding)
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
    private var buttonWidth: CGFloat? {
        if _buttonHeight != nil {
            return nil
        }
        return _size.width == .infinity ? nil : _size.width
    }
    private var buttonHeight: CGFloat {
        if let height = _buttonHeight {
            return height
        }
        return _size.height
    }
    
    private var buttonMaxWidth: CGFloat? {
        guard _buttonHeight != nil else { return  nil }
        return _size.width == .infinity ? .infinity : nil
    }

    // MARK: - Body
    var body: some View {
        Button(action: _action) {
            textView
        }
        .frame(
            width: buttonWidth,
            height: buttonHeight
        )
        .frame(maxWidth: buttonMaxWidth,alignment: .center)
        .background(backgroundView)
        .scaleEffect(_isActive ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: _isActive)
    }
}

// MARK: - Chain Modifier Extensions
extension WTextButton {
    // Style modifiers (WIconButton-style approach)
    func buttonStyle(_ style: WTextButtonStyle) -> WTextButton {
        var copy = self
        copy._style = style
        return copy
    }
    
    func buttonSize(_ size: CGSize) -> WTextButton {
        var copy = self
        copy._size = size
        return copy
    }
    
    func buttonSize(width: CGFloat, height: CGFloat) -> WTextButton {
        buttonSize(CGSize(width: width, height: height))
    }
    
    func height(_ height: CGFloat = 45) -> WTextButton {
        print("Height: \(height)")
        var copy = self
        copy._buttonHeight = height
        return copy
    }
    
    func fullWidth(height: CGFloat = 45) -> WTextButton {
        var copy = self
        copy._size = CGSize(width: .infinity, height: height)
        return copy
    }
    
    func font(_ font: Font) -> WTextButton {
        var copy = self
        copy._font = font
        return copy
    }
    
    func customFont(_ fontName: FontName, size: CGFloat) -> WTextButton {
        var copy = self
        copy._font = .custom(fontName, size: size)
        return copy
    }
    
    func backgroundColor(_ color: Color) -> WTextButton {
        var copy = self
        copy._backgroundColor = color
        return copy
    }
    
    func foregroundColor(_ color: Color) -> WTextButton {
        var copy = self
        copy._foregroundColor = color
        return copy
    }
    
    func cornerRadius(_ radius: CGFloat) -> WTextButton {
        var copy = self
        copy._cornerRadius = radius
        return copy
    }
    
    func padding(horizontal: CGFloat, vertical: CGFloat) -> WTextButton {
        var copy = self
        copy._horizontalPadding = horizontal
        copy._verticalPadding = vertical
        return copy
    }
    
    func padding(_ padding: CGFloat) -> WTextButton {
        var copy = self
        copy._horizontalPadding = padding
        copy._verticalPadding = padding
        return copy
    }
    
    func horizontalPadding(_ padding: CGFloat) -> WTextButton {
        var copy = self
        copy._horizontalPadding = padding
        return copy
    }
    
    func verticalPadding(_ padding: CGFloat) -> WTextButton {
        var copy = self
        copy._verticalPadding = padding
        return copy
    }
    
    func active(_ isActive: Bool) -> WTextButton {
        var copy = self
        copy._isActive = isActive
        return copy
    }
    
    // MARK: - Enhanced Modifiers (WIconButton style)
    
    // Quick style presets
    func outlined(color: Color = .blue) -> WTextButton {
        var copy = self
        copy._style = .outlined
        copy._backgroundColor = .clear
        copy._foregroundColor = color
        return copy
    }
    
    func contained(backgroundColor: Color = .blue, foregroundColor: Color = .white) -> WTextButton {
        var copy = self
        copy._backgroundColor = backgroundColor
        copy._foregroundColor = foregroundColor
        return copy
    }
    
    func minimal(color: Color = .primary) -> WTextButton {
        var copy = self
        copy._style = .minimal
        copy._backgroundColor = .clear
        copy._foregroundColor = color
        return copy
    }
    
    // State modifiers
    func disabled() -> WTextButton {
        var copy = self
        copy._backgroundColor = Color.gray.opacity(0.3)
        copy._foregroundColor = .gray
        return copy
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 30) {
            // Keyboard Style Examples
            VStack(spacing: 16) {
                Text("Keyboard Buttons")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        WTextButton("space")
                            .buttonStyle(.outlined)
                            .backgroundColor(Color(hex: "#E8E8E8"))
                            .foregroundColor(.black)
                            .buttonSize(width: 120, height: 45)
                        
                        WTextButton("return")
                            .buttonStyle(.contained)
                            .backgroundColor(Color(hex: "#007AFF"))
                            .foregroundColor(.white)
                            .buttonSize(width: 80, height: 45)
                        
                        WTextButton("a")
                            .buttonStyle(.outlined)
                            .backgroundColor(Color(hex: "#E8E8E8"))
                            .foregroundColor(.black)
                            .buttonSize(width: 31.33, height: 45)
                            .active(true)
                    }
                }
            }
            
            Divider()
            
            WTextButton("+ Custom 11111", action: { print("Custom action") })
                .buttonStyle(.contained)
                .foregroundColor(.black)
                .backgroundColor(Color(hex: "#F6F5F4"))
                .font(.custom(.interMedium, size: 14))
                .horizontalPadding(15)
                .verticalPadding(9)
                .height(35)
                .cornerRadius(106)
            // Chain Modifier Examples
            VStack(spacing: 16) {
                Text("WTextButton Examples")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    HStack(spacing: 15) {
                        // Outlined text button
                        WTextButton("Cancel")
                            .buttonStyle(.outlined)
                            .outlined(color: .red)
                            .buttonSize(width: 80, height: 40)
                        
                        // Contained text button
                        WTextButton("Save")
                            .buttonStyle(.contained)
                            .contained(backgroundColor: .green, foregroundColor: .white)
                            .buttonSize(width: 80, height: 40)
                        
                        // Minimal text button
                        WTextButton("Skip")
                            .buttonStyle(.minimal)
                            .minimal(color: .blue)
                            .buttonSize(width: 60, height: 40)
                    }
                    
                    Text("Different button styles")
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
                        WTextButton("Outlined")
                            .buttonStyle(.outlined)
                            .foregroundColor(.red)
                        
                        WTextButton("Contained")
                            .buttonStyle(.contained)
                            .contained(backgroundColor: .blue, foregroundColor: .white)
                        
                        WTextButton("Minimal")
                            .buttonStyle(.minimal)
                            .foregroundColor(.red)
                    }
                    
                    Text("Outlined • Contained • Minimal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Font Examples
            VStack(spacing: 16) {
                Text("Font Variations")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    HStack(spacing: 15) {
                        WTextButton("Regular")
                            .customFont(.interRegular, size: 16)
                            .buttonStyle(.contained)
                        
                        WTextButton("Medium")
                            .customFont(.interMedium, size: 16)
                            .buttonStyle(.contained)
                        
                        WTextButton("Bold")
                            .customFont(.interBold, size: 16)
                            .buttonStyle(.contained)
                    }
                    
                    Text("Different font weights")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Full Width Examples
            VStack(spacing: 16) {
                Text("Full Width Buttons")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    WTextButton("Full Width Primary")
                        .fullWidth(height: 50)
                        .buttonStyle(.contained)
                        .backgroundColor(Color(hex: "#007AFF"))
                        .foregroundColor(.white)
                    
                    WTextButton("Full Width Secondary")
                        .fullWidth(height: 44)
                        .buttonStyle(.outlined)
                        .foregroundColor(.blue)
                    
                    WTextButton("Full Width Minimal")
                        .fullWidth(height: 40)
                        .buttonStyle(.minimal)
                        .foregroundColor(.red)
                    
                    Text("Buttons that expand to fill width")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }        
        }
        .padding()
    }
}
