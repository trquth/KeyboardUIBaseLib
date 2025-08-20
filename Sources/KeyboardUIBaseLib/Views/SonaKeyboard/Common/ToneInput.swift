//
//  SuggestionInput.swift
//  KeyboardBaseIOS
//
//  Created by Thien Tran-Quan on 17/8/25.
//

import SwiftUI

struct ToneInput: View {
    @Binding private var text: String
    private let placeholder: String
    private let onAdd: () -> Void
    
    init(_ placeholder: String, text: Binding<String>, onAdd: @escaping () -> Void) {
        self.placeholder = placeholder
        self._text = text
        self.onAdd = onAdd
    }
    
    var body: some View {
        WTextInput(placeholder, text: $text)
            .filled()
            .backgroundColor(Color(.systemGray6))
            .borderColor(Color(.systemGray4))
            .cornerRadius(23)
            .height(48)
            .rightView {
                WTextButton("Add", action: onAdd)
                    .buttonStyle(.contained)
                    .backgroundColor(.black)
                    .foregroundColor(.white)
                    .cornerRadius(109.36)
                    .height(37.24)
                    .font(.custom(.interMedium, size: 14.48))
            }
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 0)
    }
}

#Preview {
    ToneInput("Add custom tone...", text: .constant("")) {
        print("Add tapped")
    }.padding()
}
