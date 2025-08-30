////
////  KeyboardViewController.swift
////  MyKeyboard2Extension
////
////  Created by Thien Tran-Quan on 21/8/25.
////
//
//import UIKit
//import SwiftUI
//import Combine
//import KeyboardUIBaseLib
//
//class KeyboardViewController: UIInputViewController {
//    
//    private let keyboardHeight: CGFloat = 260
//    
//    var heightConstraint: NSLayoutConstraint?
//    
//    private var cancellables = Set<AnyCancellable>()
//    private let sharedDataVM = SharedDataViewModel()
//    
//    override func updateViewConstraints() {
//        super.updateViewConstraints()
//        
//        // Add custom view sizing constraints here
//        if let heightConstraint = heightConstraint {
//            heightConstraint.constant = keyboardHeight
//        }
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        let keyboardApp = KeyboardApp()
//            .environmentObject(sharedDataVM)
//        
//        let hosting = UIHostingController(rootView:keyboardApp)
//        addChild(hosting)
//        hosting.view.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(hosting.view)
//        
//        NSLayoutConstraint.activate([
//            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
//            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//        
//        //        heightConstraint = view.heightAnchor.constraint(equalToConstant: 280)
//        //        heightConstraint?.priority = .defaultHigh
//        //        heightConstraint?.isActive = true
//        //
//        hosting.didMove(toParent: self)
//        
//        // Start listening to shared data changes
//        setupSharedDataListener()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        // Configure keyboard appearance
//        setupKeyboardAppearance()
//    }
//    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        
//        // Adjust height constraint if needed
//        updateKeyboardHeight()
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        // Load custom fonts if needed
//        Font.registerCustomFonts()
//        
//        // Refresh UILexicon in case user added new text replacements
//        loadSupplementaryLexicon()
//    }
//    //MARK: - Listen to shared data changes
//    private func setupSharedDataListener() {
//        // Listen to translated text changes
//        sharedDataVM.$translatedText
//            .sink { [weak self] translatedText in
//                self?.handleTranslatedTextChanged(translatedText)
//            }.store(in: &cancellables)
//        
//        sharedDataVM.$pressedKey.sink { [weak self] key in
//            guard let key = key else { return }
//            self?.handleKeyPressed(key)
//            self?.updateCurrentTypingInput()
//        }.store(in: &cancellables)
//        
//        sharedDataVM.$selectedTextReplacement.sink { [weak self] replacement in
//            guard let replacement = replacement else { return }
//            self?.handleTextReplacementSelected(replacement)
//        }.store(in: &cancellables)
//    }
//    
//    private func handleTranslatedTextChanged(_ translatedText: String) {
//        print("🔄 KeyboardViewController: Translated text changed: '\(translatedText)'")
//        
//        // Only handle non-empty translated text
//        guard !translatedText.isEmpty else {
//            print("📝 Translated text is empty, ignoring")
//            return
//        }
//        //Clear text before inserting translated text
//        clearAllText()
//        insertText(translatedText)
//        print("✅ Text replacement completed")
//        
//        // Clear the translated text after processing to avoid reprocessing
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            self.sharedDataVM.clearTranslatedText()
//        }
//    }
//
//    // Method to manually trigger text update for SharedDataViewModel
//    func updateSharedDataCurrentText() {
//        let currentContext = getCurrentContext() ?? ""
//        //sharedDataVM.setCurrentText(currentContext)
//        print("📝 Updated shared data current text: '\(currentContext)'")
//    }
//    
//    // MARK: - Keyboard Configuration
//    private func setupKeyboardAppearance() {
//        // Configure the keyboard's visual appearance
//        view.backgroundColor = UIColor.systemBackground
//        
//        // Set needs display to refresh the view
//        view.setNeedsDisplay()
//    }
//    
//    private func updateKeyboardHeight() {
//        // You can adjust keyboard height based on device orientation or other factors
//        let newHeight: CGFloat
//        
//        if view.bounds.width > view.bounds.height {
//            // Landscape mode - shorter keyboard
//            newHeight = 250
//        } else {
//            // Portrait mode - taller keyboard
//            newHeight = 250
//        }
//        
//        heightConstraint?.constant = newHeight
//    }
//    
//    override func textWillChange(_ textInput: UITextInput?) {
//        // The app is about to change the document's contents. Perform any preparation here.
//    }
//    
//    override func textDidChange(_ textInput: UITextInput?) {
//        //When text input changes, this func will call with the updated text input.
//        print("📝 Text did change - updating shared data")
//        updateCurrentTypingInput()
//    }
//    
//    // MARK: - Keyboard Handling Methods
//    
//    private func handleKeyPressed(_ data: KeyItem) {
//        // Handle different types of key presses
//        print("⌨️ KeyboardViewController ::: handleKeyPressed :: Key pressed: '\(data)'")
//        guard let keyValue = data.key else {
//            insertText(data.value)
//            return
//        }
//        switch keyValue {
//        case .delete:  // Handle both text and symbol for delete
//            handleDeleteKey()
//        case .enter:     // Handle both text and newline for return
//            handleReturnKey()
//        case .space:                // Handle both text and actual space
//            handleSpaceKey()
//            //        case "caps_lock":
//            //            handleCapsLockKey()
//            //        case "next_keyboard", "globe":
//            //            advanceToNextInputMode()
//            //        case "dismiss", "hide_keyboard":
//            //            handleDismissKeyboard()
//        default:
//            insertText(data.value)
//        }
//        
//    }
//    
//    private func handleTextSubmitted(_ text: String) {
//        // Called when user presses return/enter
//        print("✅ KeyboardViewController: Text submitted: '\(text)'")
//        print("📊 Text length: \(text.count) characters")
//        
//        // Clear text replacement suggestions after submit
//        //textReplacementsVM.textReplacements = []
//        
//        // Additional submit logic can be added here:
//        // - Analytics tracking
//        // - Text validation
//        // - Custom submit behaviors based on app context
//        
//        // Notify the hosting app about the submission
//        // The app can handle this for specific actions like sending messages
//    }
//    
//    // MARK: - Specific Key Handlers
//    
//    private func handleDeleteKey() {
//        textDocumentProxy.deleteBackward()
//    }
//    
//    private func deleteAllText() {
//            // Get all text before and after cursor
//            let contextBefore = textDocumentProxy.documentContextBeforeInput ?? ""
//            let contextAfter = textDocumentProxy.documentContextAfterInput ?? ""
//            
//            // Delete all text before cursor
//            for _ in contextBefore {
//                textDocumentProxy.deleteBackward()
//            }
//            
//            // Delete all text after cursor
//            for _ in contextAfter {
//                textDocumentProxy.adjustTextPosition(byCharacterOffset: 1)
//                       textDocumentProxy.deleteBackward()
//               // textDocumentProxy.deleteForward()
//            }
//            
//            print("🗑️ KeyboardViewController: All text deleted")
//        }
//        
//        private func deleteAllTextEfficient() {
//            // Alternative efficient method using text selection
//            // Move cursor to beginning of document
//            let contextBefore = textDocumentProxy.documentContextBeforeInput ?? ""
//            let contextAfter = textDocumentProxy.documentContextAfterInput ?? ""
//            let totalLength = contextBefore.count + contextAfter.count
//            
//            // If there's no text, nothing to delete
//            guard totalLength > 0 else {
//                print("🗑️ KeyboardViewController: No text to delete")
//                return
//            }
//            
//            // Move cursor to the beginning
//            textDocumentProxy.adjustTextPosition(byCharacterOffset: -contextBefore.count)
//            
//            // Select all text and delete
//            for _ in 0..<totalLength {
//                textDocumentProxy.adjustTextPosition(byCharacterOffset: 1)
//                       textDocumentProxy.deleteBackward()
//                //textDocumentProxy.deleteForward()
//            }
//            
//            print("🗑️ KeyboardViewController: All text deleted efficiently")
//        }
//        
//        // Public method for external calls
//        public func clearAllText() {
//            deleteAllTextEfficient()
//        }
//        
//    
//    private func handleReturnKey() {
//        // Get the current text context before inserting newline
//        let currentText = getCurrentContext() ?? ""
//        print("Current text before return: '\(currentText)'")
//        
//        // Check the return key type to determine behavior
//        let returnKeyType = textDocumentProxy.returnKeyType
//        print("Return key type: \(returnKeyType?.rawValue)")
//        
//        switch returnKeyType {
//        case .send:
//            // For messaging apps - submit without newline and dismiss keyboard
//            print("📤 Send action triggered - dismissing keyboard")
//            handleTextSubmitted(currentText)
//            requestKeyboardDismissal()
//            
//        case .search:
//            // For search fields - submit search and dismiss keyboard
//            print("🔍 Search action triggered - dismissing keyboard")
//            handleTextSubmitted(currentText)
//            requestKeyboardDismissal()
//            
//        case .done, .go:
//            // For forms - submit and dismiss keyboard
//            print("✅ Done/Go action triggered - dismissing keyboard")
//            handleTextSubmitted(currentText)
//            requestKeyboardDismissal()
//            
//        case .join:
//            // For join actions - submit and dismiss keyboard
//            print("🔗 Join action triggered - dismissing keyboard")
//            handleTextSubmitted(currentText)
//            requestKeyboardDismissal()
//            
//        default:
//            // Default behavior - insert newline and submit (keep keyboard open)
//            print("📝 Default return - inserting newline")
//            textDocumentProxy.insertText("\n")
//            handleTextSubmitted(currentText)
//        }
//    }
//    
//    private func handleSpaceKey() {
//        insertText(" ")
//    }
//    
//    private func insertText(_ text: String) {
//        textDocumentProxy.insertText(text)
//    }
//    
//    // MARK: - Keyboard Utilities
//    
//    private func requestKeyboardDismissal() {
//        // For keyboard extensions, we can't directly dismiss the keyboard
//        // Instead, we need to signal completion to the host app
//        print("🔽 Attempting to signal keyboard dismissal")
//        
//        // Method 1: Use dismissKeyboard() from UIInputViewController if available
//        // This is the proper way to request dismissal in iOS
//        dismissKeyboard()
//        
//        // Method 2: For certain return key types (.send, .search, .done),
//        // the system and host app may automatically dismiss the keyboard
//        
//        // Method 3: Advance to next input mode can sometimes trigger dismissal
//        // advanceToNextInputMode()
//        
//        print("🔽 Keyboard dismissal requested via UIInputViewController.dismissKeyboard()")
//    }
//    
//    private func handleDismissKeyboard() {
//        // Note: Keyboard extensions typically can't dismiss themselves directly
//        // This would need to be handled by the host app
//        print("Keyboard dismiss requested")
//        requestKeyboardDismissal()
//    }
//    
//    // Public method to dismiss keyboard that can be called from SwiftUI views
//    func dismissCustomKeyboard() {
//        print("🔽 Public dismiss method called")
//        requestKeyboardDismissal()
//    }
//    
//    override func advanceToNextInputMode() {
//        super.advanceToNextInputMode()
//    }
//    
//    // MARK: - Context Information
//    
//    private func getCurrentContext() -> String? {
//        return textDocumentProxy.documentContextBeforeInput
//    }
//    
//    private func getContextAfter() -> String? {
//        return textDocumentProxy.documentContextAfterInput
//    }
//    
//    private func getCurrentWord() -> String? {
//        guard let contextBefore = getCurrentContext(),
//              !contextBefore.isEmpty else { return nil }
//        
//        print("🔤 KeyboardViewController :: Current context before input: '\(contextBefore)'")
//        
//        // Find the last word (sequence of letters/numbers without spaces or punctuation)
//        let words = contextBefore.components(
//            separatedBy: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
//        )
//        return words.last?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? words.last : nil
//    }
//    
//    // MARK: - Supplementary Lexicon Management
//    
//    private func loadSupplementaryLexicon() {
//        requestSupplementaryLexicon { [weak self] lexicon in
//            DispatchQueue.main.async {
//                self?.processSupplementaryLexicon(lexicon)
//                print("📚 Loaded supplementary lexicon with \(lexicon.entries.count) entries")
//            }
//        }
//    }
//    
//    private func processSupplementaryLexicon(_ lexicon : UILexicon? = nil) {
//        guard let lexicon = lexicon else { return }
//        
//        
//        // Clear existing replacements
//        sharedDataVM.clearTextReplacements()
//        
//        var textReplacements = [TextReplacement]()
//        // Process lexicon entries
//        for entry in lexicon.entries {
//            textReplacements.append(TextReplacement(shortcut: entry.userInput, replacement: entry.documentText))
//            
//            //print("🔄 Text replacement: '\(entry.userInput)' -> '\(entry.documentText)'")
//        }
//        sharedDataVM.setTextReplacements(textReplacements)
//    }
//    
//    private func handleTextReplacementSelected(_ replacement: TextReplacement) {
//        print("🔄 Text replacement selected: \(replacement.shortcut) → \(replacement.replacement)")
//        // Get current context to find the shortcut to replace
//        if let lastWord = getCurrentWord() {
//            print("🔤 Applying text replacement for current word: '\(lastWord)'")
//            for _ in lastWord {
//                handleDeleteKey()
//            }
//        }
//        // Insert the replacement text
//        insertText(replacement.replacement)
//        
//        print("✅ Applied text replacement: '\(replacement.shortcut)' -> '\(replacement.replacement)'")
//    }
//    
//    private func updateCurrentTypingInput() {
//        if let lastWord = getCurrentWord() {
//            sharedDataVM.setCurrentTypingInput(lastWord)
//            print("Last word : \(lastWord)")  // Update current typing input
//            
//            // Also update the shared data with current context
//            let currentContext = getCurrentContext() ?? ""
//            //sharedDataVM.setCurrentText(currentContext)
//        }else {
//            sharedDataVM.clearTranslatedText()
//            // Clear shared data when no current input
//            //sharedDataVM.setCurrentText("")
//        }
//    }
//    
//    // Get the complete text in the text field
//    public func getAllText() -> String {
//        let beforeText = textDocumentProxy.documentContextBeforeInput ?? ""
//        let afterText = textDocumentProxy.documentContextAfterInput ?? ""
//        return beforeText + afterText
//    }
//    
//    // Get text length
//    public func getTextLength() -> Int {
//        let beforeText = textDocumentProxy.documentContextBeforeInput ?? ""
//        let afterText = textDocumentProxy.documentContextAfterInput ?? ""
//        return beforeText.count + afterText.count
//    }
//    
//    // Check if text field is empty
//    public func isTextFieldEmpty() -> Bool {
//        return getTextLength() == 0
//    }
//}
