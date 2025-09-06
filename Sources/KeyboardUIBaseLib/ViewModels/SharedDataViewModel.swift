//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 28/8/25.
//

import Foundation

public class SharedDataViewModel: ObservableObject {
    @Published public var pressedKey: KeyItem? = nil
    @Published public var translatedText: String = ""
    @Published public var textReplacements: [TextReplacement] = []
//    @Published public var currentTypingInput = ""
    @Published public var selectedTextReplacement: TextReplacement? = nil
    @Published private(set) var inputText = ""
    @Published private(set) var inputTextFieldValue = "" //Get text from the input field in the main app
    @Published private(set) var initInputTextFieldValue = ""
    
    @Published public var accessToken: String = ""
    
    public init() {}
    
    public init(textReplacements: [TextReplacement]) {
        self.textReplacements = textReplacements
    }
    
    public func onPressKey(_ key: KeyItem) {
        self.pressedKey = key
    }
    
    public func setTranslatedText(_ text: String) {
        self.translatedText = text
    }
    
    public func clearTranslatedText() {
        self.translatedText = ""
    }
    
    public func setTextReplacements(_ replacements: [TextReplacement]) {
        self.textReplacements = replacements
    }
    
    public func clearTextReplacements() {
        self.textReplacements = []
    }
    
//    public func setCurrentTypingInput(_ text: String) {
//        self.currentTypingInput = text
//    }
//    
//    public func clearCurrentTypingInput() {
//        self.currentTypingInput = ""
//    }
    
    public func setSelectedTextReplacement(_ replacement: TextReplacement) {
        self.selectedTextReplacement = replacement
    }
    
    public func setAccessToken(_ token: String) {
        self.accessToken = token
    }
    
    public func setTextInput(_ text: String) {
        self.inputText = text
    }
    
    public func setInputTextFieldValue(_ text: String) {
        self.inputTextFieldValue = text
    }
    
    public func setInitInputTextFieldValue(_ text: String) {
        self.initInputTextFieldValue = text
    }

}
