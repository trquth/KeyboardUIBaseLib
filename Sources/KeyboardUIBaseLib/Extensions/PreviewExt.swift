//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 22/8/25.
//

import SwiftUI

extension View {
    func keyboardFrame()-> some View {
        self.frame(height: KeyboardConfiguration.KEYBOARD_HEIGHT)
            .border(.yellow, width: 1)
    }
}
