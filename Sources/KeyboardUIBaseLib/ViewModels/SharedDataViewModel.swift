//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 28/8/25.
//

import Foundation

class SharedDataViewModel: ObservableObject {
    @Published private(set) var currentText: String = ""
    @Published private(set) var translatedText: String = ""
    
    public func setCurrentText(_ text: String) {
        self.currentText = text
    }
    
    public func setTranslatedText(_ text: String) {
        self.translatedText = text
    }
}
