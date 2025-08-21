//
//  KeyboardViewController.swift
//  MyKeyboard2Extension
//
//  Created by Thien Tran-Quan on 21/8/25.
//

import UIKit
import SwiftUI
import KeyboardUIBaseLib

class KeyboardViewController: UIInputViewController {
    
    private let keyboardHeight: CGFloat = 260
    
    var heightConstraint: NSLayoutConstraint?
    
    // Keep track of keyboard state
    private var isShiftPressed: Bool = false
    private var isCapsLockOn: Bool = false

    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
        if let heightConstraint = heightConstraint {
            heightConstraint.constant = keyboardHeight
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainView = MainView(
            onTextChanged: { [weak self] text in
                self?.handleTextChanged(text)
            },
            onKeyPressed: { [weak self] key in
                self?.handleKeyPressed(key)
            },
            onTextSubmitted: { [weak self] text in
                self?.handleTextSubmitted(text)
            }
        )
        
        let hosting = UIHostingController(rootView:mainView)
        addChild(hosting)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hosting.view)
        
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
//        heightConstraint = view.heightAnchor.constraint(equalToConstant: 280)
//        heightConstraint?.priority = .defaultHigh
//        heightConstraint?.isActive = true
//        
        hosting.didMove(toParent: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Configure keyboard appearance
        setupKeyboardAppearance()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Adjust height constraint if needed
        updateKeyboardHeight()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Load custom fonts if needed
        Font.registerCustomFonts()
    }
    
    // MARK: - Keyboard Configuration
    
    private func setupKeyboardAppearance() {
        // Configure the keyboard's visual appearance
        view.backgroundColor = UIColor.systemBackground
        
        // Set needs display to refresh the view
        view.setNeedsDisplay()
    }
    
    private func updateKeyboardHeight() {
        // You can adjust keyboard height based on device orientation or other factors
        let newHeight: CGFloat
        
        if view.bounds.width > view.bounds.height {
            // Landscape mode - shorter keyboard
            newHeight = 250
        } else {
            // Portrait mode - taller keyboard
            newHeight = 250
        }
        
        heightConstraint?.constant = newHeight
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
    }
    
    // MARK: - Keyboard Handling Methods
    
    private func handleTextChanged(_ text: String) {
        // This is called when the internal text state changes in MainView
        // You can use this to update UI or perform other operations
        print("📝 KeyboardViewController: Text changed to: '\(text)'")
    }
    
    private func handleKeyPressed(_ key: String) {
        // Handle different types of key presses
        print("⌨️ KeyboardViewController: Key pressed: '\(key)' (length: \(key.count))")
        
        switch key {
        case "delete", "backspace", "⌫":  // Handle both text and symbol for delete
            handleDeleteKey()
        case "return", "enter", "\n":     // Handle both text and newline for return
            handleReturnKey()
        case "space", " ":                // Handle both text and actual space
            handleSpaceKey()
        case "shift":
            handleShiftKey()
        case "caps_lock":
            handleCapsLockKey()
        case "next_keyboard", "globe":
            advanceToNextInputMode()
        case "dismiss", "hide_keyboard":
            handleDismissKeyboard()
        default:
            // Regular character input
            let finalText = processTextCase(key)
            insertText(finalText)
            
            // Reset shift after typing (unless caps lock is on)
            if isShiftPressed && !isCapsLockOn {
                isShiftPressed = false
            }
        }
    }
    
    private func handleTextSubmitted(_ text: String) {
        // Called when user presses return/enter
        print("✅ KeyboardViewController: Text submitted: '\(text)'")
        // The actual newline insertion is handled by handleReturnKey when onKeyPressed is called
        // This callback is mainly for notification that text was "submitted"
    }
    
    // MARK: - Specific Key Handlers
    
    private func handleDeleteKey() {
        textDocumentProxy.deleteBackward()
    }
    
    private func handleReturnKey() {
        textDocumentProxy.insertText("\n")
    }
    
    private func handleSpaceKey() {
        textDocumentProxy.insertText(" ")
    }
    
    private func handleShiftKey() {
        isShiftPressed.toggle()
        // Visual feedback could be added here
    }
    
    private func handleCapsLockKey() {
        isCapsLockOn.toggle()
        isShiftPressed = isCapsLockOn
        // Visual feedback could be added here
    }
    
    private func insertText(_ text: String) {
        textDocumentProxy.insertText(text)
    }
    
    // MARK: - Text Processing
    
    private func processTextCase(_ text: String) -> String {
        if isShiftPressed || isCapsLockOn {
            return text.uppercased()
        }
        return text.lowercased()
    }
    
    // MARK: - Keyboard Utilities
    
    private func handleDismissKeyboard() {
        // Note: Keyboard extensions typically can't dismiss themselves
        // This would need to be handled by the host app
        print("Keyboard dismiss requested")
    }
    
    override func advanceToNextInputMode() {
        super.advanceToNextInputMode()
    }
    
    // MARK: - Context Information
    
    private func getCurrentContext() -> String? {
        return textDocumentProxy.documentContextBeforeInput
    }
    
    private func getContextAfter() -> String? {
        return textDocumentProxy.documentContextAfterInput
    }

}
