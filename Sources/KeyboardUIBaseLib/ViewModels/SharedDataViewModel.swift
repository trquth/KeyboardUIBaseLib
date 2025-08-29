//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 28/8/25.
//

import Foundation

public class SharedDataViewModel: ObservableObject {
    @Published public var currentText: String = ""
    @Published public var translatedText: String = ""
    
    public init() {}
    
    public func setCurrentText(_ text: String) {
        self.currentText = text
    }
    
    public func setTranslatedText(_ text: String) {
        self.translatedText = text
    }
    
    public func clearTranslatedText() {
        self.translatedText = ""
    }
}
