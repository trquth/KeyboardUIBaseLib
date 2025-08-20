//
//  WTextInput.swift
//  KeyboardBaseIOS
//
//  Created by Thien Tran-Quan on 17/8/25.
//

import SwiftUI
import UIKit

// MARK: - WTextInput Style
enum WTextInputStyle {
    case outlined
    case filled
    case underlined
}

// MARK: - WTextInput Right Icon
struct WTextInputRightIcon {
    let systemName: String?
    let assetName: String?
    let action: (() -> Void)?
    
    init(systemName: String, action: (() -> Void)? = nil) {
        self.systemName = systemName
        self.assetName = nil
        self.action = action
    }
    
    init(assetName: String, action: (() -> Void)? = nil) {
        self.systemName = nil
        self.assetName = assetName
        self.action = action
    }
}

// MARK: - WTextInput Right View Container
struct WTextInputRightView {
    let content: AnyView
    
    init<Content: View>(@ViewBuilder content: () -> Content) {
        self.content = AnyView(content())
    }
}

// MARK: - WTextInput Left Icon
struct WTextInputLeftIcon {
    let systemName: String?
    let assetName: String?
    
    init(systemName: String) {
        self.systemName = systemName
        self.assetName = nil
    }
    
    init(assetName: String) {
        self.systemName = nil
        self.assetName = assetName
    }
}

// MARK: - WTextInput Validation
struct WTextInputValidation {
    let validator: (String) -> Bool
    let errorMessage: String
    
    @MainActor static let email = WTextInputValidation(
        validator: { text in
            let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
            return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: text)
        },
        errorMessage: "Please enter a valid email address"
    )
    
    static func minLength(_ length: Int) -> WTextInputValidation {
        return WTextInputValidation(
            validator: { $0.count >= length },
            errorMessage: "Must be at least \(length) characters"
        )
    }
    
    static func maxLength(_ length: Int) -> WTextInputValidation {
        return WTextInputValidation(
            validator: { $0.count <= length },
            errorMessage: "Must be no more than \(length) characters"
        )
    }
}

// MARK: - WTextInput
struct WTextInput: View {
    // MARK: - Properties
    private let placeholder: String
    @Binding private var text: String
    
    // Style properties
    private var _style: WTextInputStyle = .outlined
    private var _backgroundColor: Color = Color(.systemGray6)
    private var _borderColor: Color = Color(.systemGray4)
    private var _focusedBorderColor: Color = .blue
    private var _errorColor: Color = .red
    private var _textColor: Color = .primary
    private var _placeholderColor: Color = .secondary
    private var _cornerRadius: CGFloat = 8
    private var _borderWidth: CGFloat = 1
    private var _height: CGFloat = 44
    private var _font: Font = .system(size: 16)
    private var _isSecure: Bool = false
    private var _isDisabled: Bool = false
    private var _autocapitalization: TextInputAutocapitalization = .sentences
    private var _keyboardType: UIKeyboardType = .default
    private var _contentType: UITextContentType? = nil
    
    // Icon properties
    private var _rightIcon: WTextInputRightIcon?
    private var _leftIcon: WTextInputLeftIcon?
    private var _rightView: WTextInputRightView?
    
    // Validation properties
    private var _validation: WTextInputValidation?
    private var _showError: Bool = false
    
    // Focus properties
    @FocusState private var isFocused: Bool
    
    // Callbacks
    private var _onEditingChanged: ((Bool) -> Void)?
    private var _onCommit: (() -> Void)?
    
    // Computed properties
    private var hasError: Bool {
        guard let validation = _validation else { return _showError }
        return !validation.validator(text) || _showError
    }
    
    private var errorMessage: String? {
        guard hasError else { return nil }
        return _validation?.errorMessage ?? "Invalid input"
    }
    
    private var borderColor: Color {
        if hasError {
            return _errorColor
        } else if isFocused {
            return _focusedBorderColor
        } else {
            return _borderColor
        }
    }
    
    private var borderWidth: CGFloat {
        if hasError || isFocused {
            return _borderWidth + 0.5
        } else {
            return _borderWidth
        }
    }
    
    // MARK: - Initializer
    init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Main input container
            HStack(spacing: 8) {
                // Left icon
                if let leftIcon = _leftIcon {
                    Group {
                        if let systemName = leftIcon.systemName {
                            Image(systemName: systemName)
                        } else if let assetName = leftIcon.assetName {
                            Image(assetName)
                        }
                    }
                    .foregroundColor(_placeholderColor)
                    .frame(width: 16, height: 16)
                }
                
                // Text field
                Group {
                    if _isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .font(_font)
                .foregroundColor(_textColor)
                .textInputAutocapitalization(_autocapitalization)
                .keyboardType(_keyboardType)
                .textContentType(_contentType)
                .focused($isFocused)
                .onChange(of: isFocused) { _, newValue in
                    _onEditingChanged?(newValue)
                }
                .onSubmit {
                    _onCommit?()
                }
                
                // Right icon or custom view
                if let rightView = _rightView {
                    rightView.content
                } else if let rightIcon = _rightIcon {
                    Button(action: rightIcon.action ?? {}) {
                        Group {
                            if let systemName = rightIcon.systemName {
                                Image(systemName: systemName)
                            } else if let assetName = rightIcon.assetName {
                                Image(assetName)
                            }
                        }
                        .foregroundColor(_placeholderColor)
                        .frame(width: 16, height: 16)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.trailing, 6)
            .padding(.leading, _leftIcon == nil ? 16 : 6)
            .padding(.vertical, 5)
            .frame(height: _height)
            .background(backgroundView)
            .disabled(_isDisabled)
            .opacity(_isDisabled ? 0.6 : 1.0)
            
            // Error message
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(_errorColor)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .animation(.easeInOut(duration: 0.2), value: hasError)
            }
        }
    }
    
    // MARK: - Background View
    @ViewBuilder
    private var backgroundView: some View {
        switch _style {
        case .outlined:
            RoundedRectangle(cornerRadius: _cornerRadius)
                .fill(_backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: _cornerRadius)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
        case .filled:
            RoundedRectangle(cornerRadius: _cornerRadius)
                .fill(_backgroundColor)
        case .underlined:
            Rectangle()
                .fill(Color.clear)
                .overlay(
                    Rectangle()
                        .frame(height: borderWidth)
                        .foregroundColor(borderColor),
                    alignment: .bottom
                )
        }
    }
}

// MARK: - Chain Modifier Extensions
extension WTextInput {
    // Style modifiers
    func outlined() -> WTextInput {
        var input = self
        input._style = .outlined
        return input
    }
    
    func filled() -> WTextInput {
        var input = self
        input._style = .filled
        return input
    }
    
    func underlined() -> WTextInput {
        var input = self
        input._style = .underlined
        return input
    }
    
    // Appearance modifiers
    func backgroundColor(_ color: Color) -> WTextInput {
        var input = self
        input._backgroundColor = color
        return input
    }
    
    func borderColor(_ color: Color) -> WTextInput {
        var input = self
        input._borderColor = color
        return input
    }
    
    func focusedBorderColor(_ color: Color) -> WTextInput {
        var input = self
        input._focusedBorderColor = color
        return input
    }
    
    func errorColor(_ color: Color) -> WTextInput {
        var input = self
        input._errorColor = color
        return input
    }
    
    func textColor(_ color: Color) -> WTextInput {
        var input = self
        input._textColor = color
        return input
    }
    
    func placeholderColor(_ color: Color) -> WTextInput {
        var input = self
        input._placeholderColor = color
        return input
    }
    
    func cornerRadius(_ radius: CGFloat) -> WTextInput {
        var input = self
        input._cornerRadius = radius
        return input
    }
    
    func borderWidth(_ width: CGFloat) -> WTextInput {
        var input = self
        input._borderWidth = width
        return input
    }
    
    func height(_ height: CGFloat) -> WTextInput {
        var input = self
        input._height = height
        return input
    }
    
    func font(_ font: Font) -> WTextInput {
        var input = self
        input._font = font
        return input
    }
    
    // Behavior modifiers
    func secure(_ isSecure: Bool = true) -> WTextInput {
        var input = self
        input._isSecure = isSecure
        return input
    }
    
    func disabled(_ isDisabled: Bool = true) -> WTextInput {
        var input = self
        input._isDisabled = isDisabled
        return input
    }
    
    func autocapitalization(_ type: TextInputAutocapitalization) -> WTextInput {
        var input = self
        input._autocapitalization = type
        return input
    }
    
    func keyboardType(_ type: UIKeyboardType) -> WTextInput {
        var input = self
        input._keyboardType = type
        return input
    }
    
    func textContentType(_ type: UITextContentType?) -> WTextInput {
        var input = self
        input._contentType = type
        return input
    }
    
    // Icon modifiers
    func rightIcon(systemName: String, action: (() -> Void)? = nil) -> WTextInput {
        var input = self
        input._rightIcon = WTextInputRightIcon(systemName: systemName, action: action)
        return input
    }
    
    func rightIcon(assetName: String, action: (() -> Void)? = nil) -> WTextInput {
        var input = self
        input._rightIcon = WTextInputRightIcon(assetName: assetName, action: action)
        return input
    }
    
    func leftIcon(systemName: String) -> WTextInput {
        var input = self
        input._leftIcon = WTextInputLeftIcon(systemName: systemName)
        return input
    }
    
    func leftIcon(assetName: String) -> WTextInput {
        var input = self
        input._leftIcon = WTextInputLeftIcon(assetName: assetName)
        return input
    }
    
    // Custom right view modifier
    func rightView<Content: View>(@ViewBuilder content: @escaping () -> Content) -> WTextInput {
        var input = self
        input._rightView = WTextInputRightView(content: content)
        input._rightIcon = nil // Clear right icon when custom view is set
        return input
    }
    
    // Validation modifiers
    func validation(_ validation: WTextInputValidation) -> WTextInput {
        var input = self
        input._validation = validation
        return input
    }
    
    func showError(_ show: Bool = true) -> WTextInput {
        var input = self
        input._showError = show
        return input
    }
    
    // Callback modifiers
    func onEditingChanged(_ action: @escaping (Bool) -> Void) -> WTextInput {
        var input = self
        input._onEditingChanged = action
        return input
    }
    
    func onCommit(_ action: @escaping () -> Void) -> WTextInput {
        var input = self
        input._onCommit = action
        return input
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Text("Custom WTextInput Component")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(spacing: 12) {
                    // Basic examples
                    WTextInput("Enter your name", text: .constant(""))
                        .outlined()
                    
                    WTextInput("Email address", text: .constant(""))
                        .filled()
                        .keyboardType(.emailAddress)
                    
                    WTextInput("Password", text: .constant(""))
                        .underlined()
                        .secure()
                    
                    Text("Basic • Outlined • Filled • Underlined")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            VStack(spacing: 16) {
                Text("Enhanced Custom Features")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    // Left icon support
                    WTextInput("Username", text: .constant(""))
                        .outlined()
                        .leftIcon(systemName: "person.circle")
                        .rightIcon(systemName: "checkmark.circle.fill")
                    
                    // Email validation
                    WTextInput("Email", text: .constant("invalid-email"))
                        .outlined()
                        .leftIcon(systemName: "envelope")
                        .validation(.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.never)
                    
                    // Password with validation
                    WTextInput("Password", text: .constant("123"))
                        .outlined()
                        .leftIcon(systemName: "lock")
                        .validation(.minLength(6))
                        .secure()
                        .rightIcon(systemName: "eye.slash") {
                            print("Toggle visibility")
                        }
                    
                    Text("Left icons • Validation • Focus states")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            VStack(spacing: 16) {
                Text("Custom Right Views")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    // Custom button with text
                    WTextInput("Search", text: .constant(""))
                        .outlined()
                        .rightView {
                            Button("Go") {
                                print("Search action")
                            }
                            .foregroundColor(.blue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(4)
                        }
                    
                    // Toggle switch
                    WTextInput("Enable notifications", text: .constant(""))
                        .outlined()
                        .rightView {
                            Toggle("", isOn: .constant(true))
                                .labelsHidden()
                                .scaleEffect(0.8)
                        }
                    
                    // Multiple icons
                    WTextInput("Multi-action", text: .constant(""))
                        .outlined()
                        .rightView {
                            HStack(spacing: 8) {
                                Button(action: { print("Clear") }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                                Button(action: { print("Info") }) {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.blue)
                                }
                                Button(action: { print("Settings") }) {
                                    Image(systemName: "gearshape.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    
                    // Custom loading indicator
                    WTextInput("Processing...", text: .constant(""))
                        .outlined()
                        .rightView {
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                    
                    Text("Custom buttons • Toggle • Multiple icons • Loading")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            VStack(spacing: 16) {
                Text("Style Variations")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    WTextInput("Outlined Style", text: .constant(""))
                        .outlined()
                        .rightIcon(systemName: "person.fill")
                    
                    WTextInput("Filled Style", text: .constant(""))
                        .filled()
                        .rightIcon(systemName: "envelope.fill")
                    
                    WTextInput("Underlined Style", text: .constant(""))
                        .underlined()
                        .rightIcon(systemName: "lock.fill")
                    
                    Text("All styles with right icons")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}
