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
    
    // UILexicon and text replacement
    private var currentTypingInput: String = ""
    
    // Text Replacement View Model
    let keyboardInputVM = KeyboardInputVM()
    let textReplacementsVM = TextReplacementVM()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
        if let heightConstraint = heightConstraint {
            heightConstraint.constant = keyboardHeight
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // // Load UILexicon first
        // loadSupplementaryLexicon()
        
        let mainView = MainView(
            onTextChanged: { [weak self] text in
                //self?.handleTextChanged(text)
            },
            onKeyPressed: { [weak self] key in
                self?.handleKeyPressed(key)
                self?.updateCurrentTypingInput()
            },
            onTextSubmitted: { [weak self] text in
                self?.handleTextSubmitted(text)
            },
            onTextReplacementRequested: { [weak self] input in
                return self?.getTextReplacements(for: input) ?? []
            },
            onTextReplacementSelected: { [weak self] replacement in
                self?.handleTextReplacementSelected(replacement)
            }
        ).environmentObject(keyboardInputVM)
            .environmentObject(textReplacementsVM)
        
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
        
        // Refresh UILexicon in case user added new text replacements
        loadSupplementaryLexicon()
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
    
    //When text input changes, this func will call with the updated text input.
    override func textDidChange(_ textInput: UITextInput?) {
        print("🔄 KeyboardViewController: Document context changed")
        
        let inputText = getCurrentContext() ?? ""
        if inputText.isEmpty {
            //Reset current typing input if there's no text
            currentTypingInput = ""
            return;
        }
        
        
        let textInputChars = getCurrentContext() ?? ""
        print("Text before input: \(getCurrentContext() ?? "")")
        print("Text after input: \(textDocumentProxy.documentContextAfterInput ?? "")")
        print("Current input: \(textDocumentProxy.documentIdentifier.uuidString)")
    }
    
    // MARK: - Keyboard Handling Methods
    
    private func handleTextChanged(_ text: String) {
        //print("📝 KeyboardViewController: Text changed to: '\(text)'")
        
        // Update current typing input for text replacement suggestions
        //currentTypingInput = getCurrentWord() ?? ""
        //print("🔤 KeyboardViewController Current typing input: '\(currentTypingInput)'")
    }
    
    private func handleKeyPressed(_ key: String) {
        // Handle different types of key presses
        print("⌨️ KeyboardViewController ::: handleKeyPressed :: Key pressed: '\(key)'")
        
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
        print("📊 Text length: \(text.count) characters")
        
        // Clear text replacement suggestions after submit
        textReplacementsVM.textReplacements = []
        currentTypingInput = ""
        
        // Additional submit logic can be added here:
        // - Analytics tracking
        // - Text validation
        // - Custom submit behaviors based on app context
        
        // Notify the hosting app about the submission
        // The app can handle this for specific actions like sending messages
    }
    
    // MARK: - Specific Key Handlers
    
    private func handleDeleteKey() {
        textDocumentProxy.deleteBackward()
    }
    
    private func handleReturnKey() {
        // Get the current text context before inserting newline
        let currentText = getCurrentContext() ?? ""
        print("Current text before return: '\(currentText)'")
        
        // Check the return key type to determine behavior
        let returnKeyType = textDocumentProxy.returnKeyType
        print("Return key type: \(returnKeyType?.rawValue)")
        
        switch returnKeyType {
        case .send:
            // For messaging apps - submit without newline and dismiss keyboard
            print("📤 Send action triggered - dismissing keyboard")
            handleTextSubmitted(currentText)
            requestKeyboardDismissal()
            
        case .search:
            // For search fields - submit search and dismiss keyboard
            print("🔍 Search action triggered - dismissing keyboard")
            handleTextSubmitted(currentText)
            requestKeyboardDismissal()
            
        case .done, .go:
            // For forms - submit and dismiss keyboard
            print("✅ Done/Go action triggered - dismissing keyboard")
            handleTextSubmitted(currentText)
            requestKeyboardDismissal()
            
        case .join:
            // For join actions - submit and dismiss keyboard
            print("🔗 Join action triggered - dismissing keyboard")
            handleTextSubmitted(currentText)
            requestKeyboardDismissal()
            
        default:
            // Default behavior - insert newline and submit (keep keyboard open)
            print("📝 Default return - inserting newline")
            textDocumentProxy.insertText("\n")
            handleTextSubmitted(currentText)
        }
    }
    
    private func handleSpaceKey() {
        insertText(" ")
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
    
    private func requestKeyboardDismissal() {
        // For keyboard extensions, we can't directly dismiss the keyboard
        // Instead, we need to signal completion to the host app
        print("🔽 Attempting to signal keyboard dismissal")
        
        // Method 1: Use dismissKeyboard() from UIInputViewController if available
        // This is the proper way to request dismissal in iOS
        dismissKeyboard()
        
        // Method 2: For certain return key types (.send, .search, .done),
        // the system and host app may automatically dismiss the keyboard
        
        // Method 3: Advance to next input mode can sometimes trigger dismissal
        // advanceToNextInputMode()
        
        print("🔽 Keyboard dismissal requested via UIInputViewController.dismissKeyboard()")
    }
    
    private func handleDismissKeyboard() {
        // Note: Keyboard extensions typically can't dismiss themselves directly
        // This would need to be handled by the host app
        print("Keyboard dismiss requested")
        requestKeyboardDismissal()
    }
    
    // Public method to dismiss keyboard that can be called from SwiftUI views
    func dismissCustomKeyboard() {
        print("🔽 Public dismiss method called")
        requestKeyboardDismissal()
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
    
    private func getCurrentWord() -> String? {
        do {
            guard let contextBefore = getCurrentContext(),
                  !contextBefore.isEmpty else { return nil }
            
            print("🔤 KeyboardViewController :: Current context before input: '\(contextBefore)'")
            
            // Find the last word (sequence of letters/numbers without spaces or punctuation)
            let words = contextBefore.components(
                separatedBy: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
            )
            return words.last?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? words.last : nil
        } catch {
            return nil
        }
    }
    
    // MARK: - Supplementary Lexicon Management
    
    private func loadSupplementaryLexicon() {
        requestSupplementaryLexicon { [weak self] lexicon in
            DispatchQueue.main.async {
                self?.processSupplementaryLexicon(lexicon)
                print("📚 Loaded supplementary lexicon with \(lexicon.entries.count) entries")
            }
        }
    }
    
    private func processSupplementaryLexicon(_ lexicon : UILexicon? = nil) {
        guard let lexicon = lexicon else { return }
        
        // Clear existing replacements
        textReplacementsVM.textReplacements.removeAll()
        
        var textReplacements = [TextReplacement]()
        // Process lexicon entries
        for entry in lexicon.entries {
            textReplacements.append(TextReplacement(shortcut: entry.userInput, replacement: entry.documentText))
            
            //print("🔄 Text replacement: '\(entry.userInput)' -> '\(entry.documentText)'")
        }
        textReplacementsVM.textReplacements = textReplacements
    }
    
    private func getTextReplacements(for input: String) -> [TextReplacement] {
        if input.isEmpty {
            return Array(textReplacementsVM.textReplacements.prefix(5)) // Show up to 5 suggestions
        }
        
        let filtered = textReplacementsVM.textReplacements.filter { replacement in
            replacement.shortcut.lowercased().hasPrefix(input.lowercased())
        }
        
        return Array(filtered.prefix(5)) // Show up to 5 matching suggestions
    }
    
    private func handleTextReplacementSelected(_ replacement: TextReplacement) {
        print("🔄 Text replacement selected: \(replacement.shortcut) → \(replacement.replacement)")
        // Get current context to find the shortcut to replace
        if let lastWord = getCurrentWord() {
            print("🔤 Applying text replacement for current word: '\(lastWord)'")
            for _ in lastWord {
                handleDeleteKey()
            }
        }
        // Insert the replacement text
        insertText(replacement.replacement)
        
        print("✅ Applied text replacement: '\(replacement.shortcut)' -> '\(replacement.replacement)'")
    }
    
    private func updateCurrentTypingInput() {
        if let lastWord = getCurrentWord() {
            keyboardInputVM.currentTypingInput = lastWord
            print("Last word : \(lastWord)")  // Update current typing input
        }else {
            keyboardInputVM.resetCurrentTypingInput()
        }
    }
}
