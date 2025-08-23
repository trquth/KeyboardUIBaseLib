//
//  KeyItem.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 23/8/25.
//

public struct KeyItem {
    public let value: String
    public let key: KeyboardLayout.SpecialKey?
    
    public init(value: String, key: KeyboardLayout.SpecialKey? = nil) {
        self.value = value
        self.key = key
    }
    
}
