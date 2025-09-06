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
    
    public static func getAllText(_ proxy: UITextDocumentProxy) -> String {
        let contextBefore = getCurrentContext(proxy) ?? ""
        let contextAfter = getContextAfter(proxy) ?? ""
        return contextBefore + contextAfter
    }
    
    /// Get complete text from text field by moving cursor to retrieve all content
    /// This method attempts to get more text than the limited documentContext methods
    /// - Parameter proxy: UITextDocumentProxy
    /// - Returns: Complete text from the text field
    public static func getCompleteText(_ proxy: UITextDocumentProxy) -> String {
        // Store current position context
        let originalContextBefore = getCurrentContext(proxy) ?? ""
        let originalContextAfter = getContextAfter(proxy) ?? ""
        
        // If we already have content, try to get more by moving cursor
        var completeText = ""
        var allTextBefore = ""
        var allTextAfter = ""
        
        // Method 1: Move cursor to beginning and collect all text
        if !originalContextBefore.isEmpty {
            // Move cursor to the very beginning
            let beforeLength = originalContextBefore.count
            proxy.adjustTextPosition(byCharacterOffset: -beforeLength)
            
            // Collect text by moving cursor forward step by step
            var currentText = ""
            var lastText = ""
            
            repeat {
                lastText = currentText
                currentText = proxy.documentContextBeforeInput ?? ""
                
                if currentText.count > lastText.count {
                    allTextBefore = currentText
                    // Move cursor forward to get next chunk
                    proxy.adjustTextPosition(byCharacterOffset: 100) // Move in chunks
                } else {
                    break
                }
            } while currentText.count > lastText.count
            
            // Restore to original position
            proxy.adjustTextPosition(byCharacterOffset: -(allTextBefore.count - beforeLength))
        }
        
        // Method 2: Move cursor to end and collect text after
        if !originalContextAfter.isEmpty {
            let afterLength = originalContextAfter.count
            proxy.adjustTextPosition(byCharacterOffset: afterLength)
            
            var currentText = ""
            var lastText = ""
            
            repeat {
                lastText = currentText
                currentText = proxy.documentContextAfterInput ?? ""
                
                if currentText.count > lastText.count {
                    allTextAfter = currentText
                    proxy.adjustTextPosition(byCharacterOffset: -100) // Move backward in chunks
                } else {
                    break
                }
            } while currentText.count > lastText.count
            
            // Restore to original position
            proxy.adjustTextPosition(byCharacterOffset: -(afterLength - allTextAfter.count))
        }
        
        // Combine all collected text
        let finalBefore = allTextBefore.isEmpty ? originalContextBefore : allTextBefore
        let finalAfter = allTextAfter.isEmpty ? originalContextAfter : allTextAfter
        
        completeText = finalBefore + finalAfter
        
        print("🔍 KeyboardUtil :: Retrieved complete text: '\(completeText.prefix(100))...' (Length: \(completeText.count))")
        
        return completeText
    }
    
    /// Alternative method: Get all text using text selection approach
    /// - Parameter proxy: UITextDocumentProxy
    /// - Returns: Complete text using selection method
    public static func getAllTextUsingSelection(_ proxy: UITextDocumentProxy) -> String {
        // Save current selection
        let originalBefore = getCurrentContext(proxy) ?? ""
        let originalAfter = getContextAfter(proxy) ?? ""
        
        // Try to select all text by moving to beginning and selecting to end
        let beforeCount = originalBefore.count
        let afterCount = originalAfter.count
        let totalLength = beforeCount + afterCount
        
        // Move cursor to beginning
        if beforeCount > 0 {
            proxy.adjustTextPosition(byCharacterOffset: -beforeCount)
        }
        
        // Get text from beginning
        var allText = ""
        var currentPosition = 0
        
        // Collect text in chunks by moving cursor forward
        while currentPosition < totalLength {
            let currentContext = proxy.documentContextBeforeInput ?? ""
            if currentContext.count > allText.count {
                allText = currentContext
            }
            
            // Move forward
            proxy.adjustTextPosition(byCharacterOffset: min(50, totalLength - currentPosition))
            currentPosition += 50
            
            // Safety break
            if currentPosition > totalLength + 100 {
                break
            }
        }
        
        // Restore original cursor position
        let finalPosition = allText.count - beforeCount
        if finalPosition != 0 {
            proxy.adjustTextPosition(byCharacterOffset: -finalPosition)
        }
        
        print("🔍 KeyboardUtil :: Selection method retrieved: '\(allText.prefix(100))...' (Length: \(allText.count))")
        
        return allText
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
