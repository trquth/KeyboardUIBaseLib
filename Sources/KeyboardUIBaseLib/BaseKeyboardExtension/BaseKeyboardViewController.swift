//
//  KeyboardViewController.swift
//  MyKeyboard2Extension
//
//  Created by Thien Tran-Quan on 21/8/25.
//

import UIKit
import SwiftUI
import Combine

open class BaseKeyboardViewController: UIInputViewController {
    
    public let keyboardHeight: CGFloat = 260
    
    public var heightConstraint: NSLayoutConstraint?
    
    public var cancellables = Set<AnyCancellable>()
    public let sharedDataVM = SharedDataViewModel()
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
        if let heightConstraint = heightConstraint {
            heightConstraint.constant = keyboardHeight
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let keyboardApp = KeyboardApp()
            .environmentObject(sharedDataVM)
        
        let hosting = UIHostingController(rootView:keyboardApp)
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
        
        // Start listening to shared data changes
        setupSharedDataListener()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Configure keyboard appearance
        setupKeyboardAppearance()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Adjust height constraint if needed
        updateKeyboardHeight()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Load custom fonts if needed
        Font.registerCustomFonts()
        
        // Refresh UILexicon in case user added new text replacements
        loadSupplementaryLexicon()
    }
 
    public override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    public override func textDidChange(_ textInput: UITextInput?) {
        //When text input changes, this func will call with the updated text input.
        print("📝 Text did change - updating shared data")
        updateCurrentTypingInput()
    }
    
    
    public override func advanceToNextInputMode() {
        super.advanceToNextInputMode()
    }
    
 
}

//MARK: - Listen to shared data changes
extension BaseKeyboardViewController {
    public func setupSharedDataListener() {
        // Listen to translated text changes
        sharedDataVM.$translatedText
            .sink { [weak self] translatedText in
                self?.handleTranslatedTextChanged(translatedText)
            }.store(in: &cancellables)
        
        sharedDataVM.$pressedKey.sink { [weak self] key in
            guard let key = key else { return }
            self?.handleKeyPressed(key)
            self?.updateCurrentTypingInput()
        }.store(in: &cancellables)
        
        sharedDataVM.$selectedTextReplacement.sink { [weak self] replacement in
            guard let replacement = replacement else { return }
            self?.handleTextReplacementSelected(replacement)
        }.store(in: &cancellables)
    }
}

//MARK: - Handle translated text changes
extension BaseKeyboardViewController {
    func handleTranslatedTextChanged(_ translatedText: String) {
        print("🔄 KeyboardViewController: Translated text changed: '\(translatedText)'")
        
        // Only handle non-empty translated text
        guard !translatedText.isEmpty else {
            print("📝 Translated text is empty, ignoring")
            return
        }
        //Clear text before inserting translated text
        KeyboardUtil.clearAllText(textDocumentProxy)
        KeyboardUtil.insertText(textDocumentProxy, text: translatedText)
        print("✅ Text replacement completed")
        
        // Clear the translated text after processing to avoid reprocessing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.sharedDataVM.clearTranslatedText()
        }
    }
}

// MARK: - Specific Key Handlers
extension BaseKeyboardViewController {
    func handleKeyPressed(_ data: KeyItem) {
        // Handle different types of key presses
        print("⌨️ KeyboardViewController ::: handleKeyPressed :: Key pressed: '\(data)'")
        guard let keyValue = data.key else {
            KeyboardUtil.insertText(textDocumentProxy, text: data.value)
            return
        }
        switch keyValue {
        case .delete:  // Handle both text and symbol for delete
            handleDeleteKey()
        case .enter:     // Handle both text and newline for return
            handleReturnKey()
        case .space:                // Handle both text and actual space
            handleSpaceKey()
            //        case "caps_lock":
            //            handleCapsLockKey()
            //        case "next_keyboard", "globe":
            //            advanceToNextInputMode()
            //        case "dismiss", "hide_keyboard":
            //            handleDismissKeyboard()
        default:
            KeyboardUtil.insertText(textDocumentProxy, text: data.value)
        }
    }
    
    func handleDeleteKey() {
        KeyboardUtil.deleteBackward(textDocumentProxy)
    }
    
    func handleSpaceKey() {
        KeyboardUtil.insertText(textDocumentProxy,text: " ")
    }
    
    func handleReturnKey() {
        // Get the current text context before inserting newline
        let currentText = KeyboardUtil.getCurrentContext(textDocumentProxy) ?? ""
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
            KeyboardUtil.insertText(textDocumentProxy,text: "\n")
            handleTextSubmitted(currentText)
        }
    }

    func handleTextSubmitted(_ text: String) {
        // Called when user presses return/enter
        print("✅ KeyboardViewController: Text submitted: '\(text)'")
        print("📊 Text length: \(text.count) characters")
        
        // Clear text replacement suggestions after submit
        //textReplacementsVM.textReplacements = []
        
        // Additional submit logic can be added here:
        // - Analytics tracking
        // - Text validation
        // - Custom submit behaviors based on app context
        
        // Notify the hosting app about the submission
        // The app can handle this for specific actions like sending messages
    }
}

// MARK: - Keyboard Utilities
extension BaseKeyboardViewController {
    func requestKeyboardDismissal() {
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
    
    func handleDismissKeyboard() {
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
}

// MARK: - Supplementary Lexicon Management
extension BaseKeyboardViewController {

    public func loadSupplementaryLexicon() {
        requestSupplementaryLexicon { [weak self] lexicon in
            DispatchQueue.main.async {
                self?.processSupplementaryLexicon(lexicon)
                print("📚 Loaded supplementary lexicon with \(lexicon.entries.count) entries")
            }
        }
    }
    
    public func processSupplementaryLexicon(_ lexicon : UILexicon? = nil) {
        guard let lexicon = lexicon else { return }
        
        
        // Clear existing replacements
        sharedDataVM.clearTextReplacements()
        
        var textReplacements = [TextReplacement]()
        // Process lexicon entries
        for entry in lexicon.entries {
            textReplacements.append(TextReplacement(shortcut: entry.userInput, replacement: entry.documentText))
            
            //print("🔄 Text replacement: '\(entry.userInput)' -> '\(entry.documentText)'")
        }
        sharedDataVM.setTextReplacements(textReplacements)
    }
    
    public func handleTextReplacementSelected(_ replacement: TextReplacement) {
        print("🔄 Text replacement selected: \(replacement.shortcut) → \(replacement.replacement)")
        // Get current context to find the shortcut to replace
        if let lastWord = KeyboardUtil.getCurrentWord(textDocumentProxy) {
            print("🔤 Applying text replacement for current word: '\(lastWord)'")
            for _ in lastWord {
                handleDeleteKey()
            }
        }
        // Insert the replacement text
        KeyboardUtil.insertText(textDocumentProxy, text: replacement.replacement)
        
        print("✅ Applied text replacement: '\(replacement.shortcut)' -> '\(replacement.replacement)'")
    }
}

// MARK: - Current Typing Input Management
extension BaseKeyboardViewController {
    func updateCurrentTypingInput() {
        if let lastWord = KeyboardUtil.getCurrentWord(textDocumentProxy) {
            sharedDataVM.setCurrentTypingInput(lastWord)
            print("Last word : \(lastWord)")  // Update current typing input
            
            // Also update the shared data with current context
            let currentContext = KeyboardUtil.getCurrentContext(textDocumentProxy) ?? ""
            //sharedDataVM.setCurrentText(currentContext)
        }else {
            sharedDataVM.clearTranslatedText()
            // Clear shared data when no current input
            //sharedDataVM.setCurrentText("")
        }
    }
}

// MARK: - Keyboard Configuration
extension BaseKeyboardViewController {
     func setupKeyboardAppearance() {
        // Configure the keyboard's visual appearance
        view.backgroundColor = UIColor.systemBackground
        
        // Set needs display to refresh the view
        view.setNeedsDisplay()
    }
    func updateKeyboardHeight() {
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
}
