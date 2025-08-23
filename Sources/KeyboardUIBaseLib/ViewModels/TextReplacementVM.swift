//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 21/8/25.
//

import Foundation
import SwiftUI

public final class TextReplacementVM: ObservableObject {    
    @Published public var textReplacements: [TextReplacement] = []
    
    public init() {
    }
    
    public init(textReplacements: [TextReplacement]) {
        self.textReplacements = textReplacements
    }
    
    func findTextReplacements(for shortcut: String) -> [TextReplacement]{
        //print("Filtering suggestions for input: \(currentInput)")
        if shortcut.isEmpty || textReplacements.isEmpty {
            return []
        }
        // Filter text replacements based on the shortcut
        let filtered = textReplacements.filter { replacement in
            replacement.shortcut.lowercased().hasPrefix(shortcut.lowercased())
        }
        
        return Array(filtered.prefix(5)) // Show up to 5 matching suggestions
    }
}

