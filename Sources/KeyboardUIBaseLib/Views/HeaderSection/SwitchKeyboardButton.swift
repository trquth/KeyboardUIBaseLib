//
//  SwitchKeyboardButton.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 22/8/25.
//

import SwiftUI

struct SwitchKeyboardButton: View {
    @EnvironmentObject var keyboardInputVM : KeyboardInputVM
    
    var body: some View {
        Circle()
            .fill(Color.black)
            .frame(width: 42, height: 42)
            .onTapGesture {
                print("Switching to text keyboard \(keyboardInputVM.currentKeyboard)")
                withAnimation(.easeInOut(duration: 0.3)) {                    keyboardInputVM.switchKeyboard(keyboardInputVM.currentKeyboard)
                }
             
            }
    }
}

#Preview {
    SwitchKeyboardButton()
        .environmentObject(KeyboardInputVM())
}
