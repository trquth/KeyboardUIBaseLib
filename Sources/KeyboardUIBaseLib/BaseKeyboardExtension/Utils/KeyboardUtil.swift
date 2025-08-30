//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 30/8/25.
//

import UIKit

@MainActor
struct KeyboardUtil {
    // MARK: - Context Information
    static func getCurrentContext(_ proxy: UITextDocumentProxy) -> String? {
        return proxy.documentContextBeforeInput
    }
    
    static func getContextAfter(_ proxy: UITextDocumentProxy) -> String? {
        return proxy.documentContextAfterInput
    }
    
    static func insertText(_ proxy: UITextDocumentProxy,text: String) {
        proxy.insertText(text)
    }
    
    static func getCurrentWord(_ proxy: UITextDocumentProxy) -> String? {
        guard let contextBefore = getCurrentContext(proxy),
              !contextBefore.isEmpty else { return nil }
        
        print("🔤 KeyboardUtil :: Current context before input: '\(contextBefore)'")
        
        // Find the last word (sequence of letters/numbers without spaces or punctuation)
        let words = contextBefore.components(
            separatedBy: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        )
        return words.last?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? words.last : nil
    }
    
    //MARK: - Detete
    static func deleteBackward(_ proxy: UITextDocumentProxy) {
        proxy.deleteBackward()
    }
    
    private static func deleteAllTextEfficient(_ proxy: UITextDocumentProxy) {
        // Alternative efficient method using text selection
        // Move cursor to beginning of document
        let totalLength = getTextLength(proxy)
        
        // If there's no text, nothing to delete
        guard totalLength > 0 else {
            print("🗑️ KeyboardViewController: No text to delete")
            return
        }
        
        let contextBefore = getCurrentContext(proxy) ?? ""
        // Move cursor to the beginning
        proxy.adjustTextPosition(byCharacterOffset: -contextBefore.count)
        
        // Select all text and delete
        for _ in 0..<totalLength {
            proxy.adjustTextPosition(byCharacterOffset: 1)
            deleteBackward(proxy)
        }
        
        print("🗑️ KeyboardViewController: All text deleted efficiently")
    }
    
    static func clearAllText(_ proxy: UITextDocumentProxy) {
        KeyboardUtil.deleteAllTextEfficient(proxy)
    }
    
    //MARK: - Check
    // Get text length
    public static func getTextLength(_ proxy: UITextDocumentProxy) -> Int {
        let contextBefore = getCurrentContext(proxy) ?? ""
        let contextAfter = getContextAfter(proxy) ?? ""
        return contextBefore.count + contextAfter.count
    }
    
    // Check if text field is empty
    public static func isTextFieldEmpty(_ proxy: UITextDocumentProxy) -> Bool {
        return getTextLength(proxy) == 0
    }
}
