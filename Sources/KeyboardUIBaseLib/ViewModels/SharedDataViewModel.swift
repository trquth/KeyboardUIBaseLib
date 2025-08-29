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
    @Published public var currentTypingInput = ""
    @Published public var selectedTextReplacement: TextReplacement? = nil
    
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
    
    public func setCurrentTypingInput(_ text: String) {
        self.currentTypingInput = text
    }
    
    public func clearCurrentTypingInput() {
        self.currentTypingInput = ""
    }
    
    public func setSelectedTextReplacement(_ replacement: TextReplacement) {
        self.selectedTextReplacement = replacement
    }
}
