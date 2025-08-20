//
//  DeleteTooltip.swift
//  KeyboardBaseIOS
//
//  Created by Thien Tran-Quan on 17/8/25.
//

import SwiftUI


// MARK: - Tooltip with Arrow
struct DeleteTooltip: View {
    let onDelete: () -> Void
    
    
    init(onDelete: @escaping () -> Void) {
        self.onDelete = onDelete
    }

    
    private var tooltipBody: some View {
        Button(action: onDelete) {
            HStack(spacing: 8){
                Circle().fill(Color(hex:"#5492F6"))
                    .frame(width: 28, height: 28)
                    .overlay(
                        WImage("close_ico")
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 8, height: 8)
                        )
                
                WText("Delete")
                    .font(.custom(.interMedium, size: 14))
                    .foregroundColor(.white)
                    
            }.padding(.leading, 4)
                .padding(.trailing, 12)
                .padding(.vertical, 4)
                .background(Color.blue)
                .cornerRadius(100)
        }
        .buttonStyle(PlainButtonStyle())
        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
    }
    
    private var arrow: some View {
        Triangle()
            .fill(Color.blue)
            .frame(width: 12, height: 8)
            .rotationEffect(.degrees(180))
    }
    
    
    var body: some View {
        VStack(spacing: 0) {
            tooltipBody
            arrow
        }
    }
}

// MARK: - Triangle Shape for Arrow
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    VStack(spacing: 40) {
        // Basic tooltip
        DeleteTooltip {
            print("Delete tapped")
        }
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
