//
//  ConfirmationModal.swift
//  KeyboardBaseIOS
//
//  Created by Thien Tran-Quan on 17/8/25.
//

import SwiftUI

struct DeleteToneConfirmationModal: View {
    let title: String
    let cancelAction: () -> Void
    let deleteAction: () -> Void
    
    init(
        title: String,
        onCancel: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.title = title
        self.cancelAction = onCancel
        self.deleteAction = onDelete
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Title
            WText(title)
                .font(.custom(.interMedium, size: 17))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            // Buttons
            VStack(spacing: 8) {
                // Cancel button (black)
                WTextButton("Cancel", action: cancelAction)
                    .buttonStyle(.contained)
                    .backgroundColor(.black)
                    .foregroundColor(.white)
                    .cornerRadius(25)
                    .height(40)
                    .font(.custom(.interMedium, size: 16))
                    .fullWidth()
                
                // Confirm button (gray)
                WTextButton("Delete", action: deleteAction)
                    .buttonStyle(.contained)
                    .backgroundColor(Color(hex: "#F2F2F2"))
                    .foregroundColor(.black)
                    .cornerRadius(25)
                    .height(40)
                    .font(.custom(.interMedium, size: 16))
                    .fullWidth()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 22)
        .frame(maxWidth: .infinity,maxHeight: .infinity, alignment: .center)
        .background(.white)
        
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.3)
            .ignoresSafeArea()
        
        VStack(spacing: 40) {
            // Delete confirmation (matching the image)
            DeleteToneConfirmationModal(
                title: "Delete Tone?",
                onCancel: { print("Cancel tapped") },
                onDelete: { print("Delete tapped") }
            )
            
        }
    }
}
