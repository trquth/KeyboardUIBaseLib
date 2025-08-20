//
//  ChipView.swift
//  BaseKeyboard
//
//  Created by Thien Tran-Quan on 16/8/25.
//

import SwiftUI

enum ChipSize {
    case small
    case normal
    
    var height: CGFloat {
        switch self {
        case .small: return 35
        case .normal: return 46
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .small: return 15
        case .normal: return 40
        }
    }
    
    var verticalPadding: CGFloat {
        switch self {
        case .small: return 9
        case .normal: return 14
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .small: return 14
        case .normal: return 15
        }
    }
}

struct ChipView: View {
    let title: String
    let isSelected: Bool
    var size: ChipSize = .normal
    let action: () -> Void
    
    var body: some View {
        WTextButton(title, action: action)
            .buttonStyle(.contained)
            .foregroundColor(.black)
            .backgroundColor(Color(hex: "#F6F5F4"))
            .customFont(.interMedium, size: size.fontSize)
            .height(size.height)
            .cornerRadius(106)
            .horizontalPadding( size.horizontalPadding)
            .verticalPadding(size.verticalPadding)
    }
}

#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 12) {
            ChipView(title: "Small Chip", isSelected: false, size: .small) {
                print("Small chip tapped")
            }
            
            ChipView(title: "Small Selected", isSelected: true, size: .small) {
                print("Small selected tapped")
            }
        }
        
        HStack(spacing: 12) {
            ChipView(title: "Normal Chip", isSelected: false, size: .normal) {
                print("Normal chip tapped")
            }
            
            ChipView(title: "Normal Selected", isSelected: true, size: .normal) {
                print("Normal selected tapped")
            }
        }
        
        // Default size (normal)
        HStack(spacing: 12) {
            ChipView(title: "Default Size", isSelected: false, action: {})
            ChipView(title: "Default Selected", isSelected: true, action: {})
        }
    }
    .padding()
}
