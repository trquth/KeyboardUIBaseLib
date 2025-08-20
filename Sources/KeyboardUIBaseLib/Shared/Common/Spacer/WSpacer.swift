//
//  WSpacer.swift
//  BaseKeyboard
//
//  Created by Thien Tran-Quan on 17/8/25.
//

import SwiftUI

struct WSpacer: View {
    private var minLength: CGFloat?
    
    init(_ minLength: CGFloat? = nil) {
        self.minLength = minLength
    }
    
    var body: some View {
        if let minLength = minLength {
            Spacer(minLength: minLength)
        } else {
            Spacer()
        }
    }
}

struct WVSpacer: View {
    private var value: CGFloat
    
    init(_ value: CGFloat = 0) {
        self.value = value
    }
    
    var body: some View {
        Spacer()
            .frame(height: value)

    }
}

struct WHSpacer: View {
    private var value: CGFloat
    
    init(_ value: CGFloat = 0) {
        self.value = value
    }
    
    var body: some View {
        Spacer()
            .frame(width: value)

    }
}
