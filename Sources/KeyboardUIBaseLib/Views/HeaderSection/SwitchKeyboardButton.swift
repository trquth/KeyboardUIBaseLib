//
//  SwitchKeyboardButton.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 22/8/25.
//

import SwiftUI

struct SwitchKeyboardButton: View {
    var switchMode: (() -> Void)
    
    var body: some View {
        Circle()
            .fill(Color.black)
            .frame(width: 42, height: 42)
            .onTapGesture{
                switchMode()
            }
    }
}

#Preview {
    SwitchKeyboardButton{
        print("Switch keyboard tapped")
    }
}
