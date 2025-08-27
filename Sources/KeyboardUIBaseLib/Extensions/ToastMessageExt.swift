//
//  SwiftUIView.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 27/8/25.
//

import SwiftUI
// MARK: - Toast View Modifier
extension View {
    func displayToastMessage(_ manager: ToastMessageManager) -> some View {
        ZStack {
            self
            
            if manager.isVisible, let toast = manager.currentToast {
                VStack {
                    Spacer()
                    
                    toast
                        .padding(.horizontal, 16)
                        .padding(.bottom, 10)
                        // Simple bottom slide animation with opacity
                        .opacity(manager.isVisible ? 1.0 : 0.0)
                        .offset(y: manager.isVisible ? 0 : 80)
                        .onTapGesture {
                            manager.hide()
                        }
                }
                .zIndex(1000)
            }
        }
    }
}
