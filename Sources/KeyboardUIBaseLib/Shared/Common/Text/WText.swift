//
//  WText.swift
//  BaseKeyboard
//
//  Created by Thien Tran-Quan on 16/8/25.
//

import SwiftUI

// MARK: - Unified WText Component
public struct WText: View {
    // MARK: - Properties (WIconButton style)
    private var _text: String
    private var _font: Font
    private var _color: Color
    private var _alignment: TextAlignment
    private var _lineLimit: Int?
    private var _multilineTextAlignment: TextAlignment
    
    // MARK: - Initializer (WIconButton style)
    public  init(
        _ text: String,
        font: Font = .system(size: 16),
        color: Color = .primary,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        multilineTextAlignment: TextAlignment = .leading
    ) {
        self._text = text
        self._font = font
        self._color = color
        self._alignment = alignment
        self._lineLimit = lineLimit
        self._multilineTextAlignment = multilineTextAlignment
    }
    
    // MARK: - Body
   public var body: some View {
        Text(_text)
            .font(_font)
            .foregroundColor(_color)
            .multilineTextAlignment(_multilineTextAlignment)
            .lineLimit(_lineLimit)
    }
}

// MARK: - Chain Modifier Extensions
extension WText {
    // Font modifiers
    func font(_ font: Font) -> WText {
        var copy = self
        copy._font = font
        return copy
    }
    
    func fontSize(_ size: CGFloat) -> WText {
        var copy = self
        copy._font = .system(size: size)
        return copy
    }
    
    public func customFont(_ fontName: FontName, size: CGFloat) -> WText {
        var copy = self
        copy._font = .custom(fontName, size: size)
        return copy
    }
    
    // Color modifiers
    func color(_ color: Color) -> WText {
        var copy = self
        copy._color = color
        return copy
    }
    
    func foregroundColor(_ color: Color) -> WText {
        var copy = self
        copy._color = color
        return copy
    }
    
    // Text alignment modifiers
    func alignment(_ alignment: TextAlignment) -> WText {
        var copy = self
        copy._alignment = alignment
        return copy
    }
    
    func multilineTextAlignment(_ alignment: TextAlignment) -> WText {
        var copy = self
        copy._multilineTextAlignment = alignment
        return copy
    }
    
    // Line limit modifiers
    func lineLimit(_ limit: Int?) -> WText {
        var copy = self
        copy._lineLimit = limit
        return copy
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 30) {
            // Basic Text Examples
            VStack(spacing: 16) {
                Text("WText Examples")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    // Default text
                    WText("Default WText")
                    
                    // Custom font and size
                    WText("Custom Inter Bold")
                        .customFont(.interBold, size: 20)
                        .color(.blue)
                    
                    // Chain modifiers
                    WText("Chain Modifiers Example")
                        .customFont(.interMedium, size: 18)
                        .color(.red)
                        .multilineTextAlignment(.center)
                }
            }
            
            Divider()
            
            // Font Variations
            VStack(spacing: 16) {
                Text("Font Variations")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 12) {
                    WText("Inter Regular - The quick brown fox")
                        .customFont(.interRegular, size: 16)
                    
                    WText("Inter Medium - The quick brown fox")
                        .customFont(.interMedium, size: 16)
                    
                    WText("Inter Bold - The quick brown fox")
                        .customFont(.interBold, size: 16)
                }
            }
            
            Divider()
            
            // Color Examples
            VStack(spacing: 16) {
                Text("Color Examples")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    WText("Primary Color")
                        .color(.primary)
                    
                    WText("Secondary Color")
                        .color(.secondary)
                    
                    WText("Blue Color")
                        .color(.blue)
                    
                    WText("Red Color")
                        .color(.red)
                }
            }
        }
        .padding()
    }
}
