//
//  AddButton.swift
//  BaseKeyboard
//
//  Created by Thien Tran-Quan on 17/8/25.
//

import SwiftUI

struct AddToneButton: View {
    let action: () -> Void
    
    init(
        action: @escaping () -> Void = {}
    ) {
        self.action = action
    }
        
    var body: some View {
        WTextButton("+ Custom", action: action)
            .buttonStyle(.contained)
            .foregroundColor(.black)
            .backgroundColor(Color(hex: "#F6F5F4"))
            .font(.custom(.interMedium, size: 14))
            .horizontalPadding(15)
            .verticalPadding(9)
            .height(35)
            .cornerRadius(106)
    }
}

#Preview {
    AddToneButton {
        print("Add New tapped")
    }
}
