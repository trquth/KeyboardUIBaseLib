//
//  SwiftUIView.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 26/8/25.
//

import SwiftUI

struct QuickTaskButton: View {
    private var _iconName: String
    private var _iconSize: CGSize
    private var _action: () -> Void
    private var _isLoading: Bool
    private var _isDisabled: Bool
    private var _foregroundColor: Color = .black
    private let _cornerRadius: CGFloat  =  16
    private let _size: CGSize = CGSize(width: 45, height: 45)
    private let _backgroundColor: Color = Color(hex: "#F6F5F4")
    
    init(
        _ iconName: String,
        iconSize: CGSize = CGSize(width: 15.76, height: 18.91),
        size: CGSize = CGSize(width: 45, height: 45),
        cornerRadius: CGFloat = 16,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void = {}
    ) {
        self._iconName = iconName
        self._iconSize = iconSize
        self._isLoading = isLoading
        self._isDisabled = isDisabled
        self._action = action
    }
    
    var body: some View {
        WIconButton(_iconName, action: _action)
            .buttonStyle(.contained)
            .backgroundColor(_backgroundColor)
            .foregroundColor(_foregroundColor)
            .buttonSize(width: _size.width, height: _size.height)
            .iconSize(width: _iconSize.width, height: _iconSize.height)
            .cornerRadius(_cornerRadius)
            .disable(_isLoading || _isDisabled)
            .overlay(
                // Show dots indicator when loading
                Group {
                    if _isLoading {
                        RoundedRectangle(cornerRadius: _cornerRadius)
                            .fill(.black)
                            .overlay(
                                ActivityIndicator(
                                    size: 20,
                                    color: .white,
                                    style: .dots
                                )
                            )
                    }
                }
            )
    }
}

// MARK: - Chain Modifier Extensions
extension QuickTaskButton {
    // Style modifiers
    
    func iconSize(_ iconSize: CGSize) -> QuickTaskButton {
        var copy = self
        copy._iconSize = iconSize
        return copy
    }
    
    func iconSize(width: CGFloat, height: CGFloat) -> QuickTaskButton {
        iconSize(CGSize(width: width, height: height))
    }
        
    func loading(_ isLoading: Bool) -> QuickTaskButton {
        var copy = self
        copy._isLoading = isLoading
        return copy
    }
    
    func disabled(_ isDisabled: Bool) -> QuickTaskButton {
        var copy = self
        copy._isDisabled = isDisabled
        return copy
    }
}



#Preview {
    VStack(spacing: 20) {
        // Normal state
        QuickTaskButton("text_editor_ico") {
            print("Text editor tapped")
        }
        
        // Loading state
        QuickTaskButton("emoji_ico", isLoading: true) {
            print("Emoji tapped")
        }
        
        // Disabled state
        QuickTaskButton("delete_ico", isDisabled: true) {
            print("Delete tapped")
        }
        
        // Custom size with loading
        QuickTaskButton("enter_ico", iconSize: CGSize(width: 12, height: 15), isLoading: true) {
            print("Enter tapped")
        }
        
        // Interactive demo
        LoadingButtonDemo()
    }
}

struct LoadingButtonDemo: View {
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 15) {
            QuickTaskButton("text_editor_ico", isLoading: isLoading) {
                isLoading = true
                
                // Simulate API call
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isLoading = false
                }
            }
            
            Text(isLoading ? "Loading..." : "Tap to start loading")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}
