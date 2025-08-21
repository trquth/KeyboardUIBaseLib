//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 21/8/25.
//

import Foundation

public final class TextReplacementVM: ObservableObject {
    @Published public var textReplacements: [TextReplacement] = []
    
    public init() {
    }
}

