//
//  ActivityIndicator.swift
//  KeyboardUIBaseLib
//
//  Created by Assistant on 26/8/25.
//

import SwiftUI

struct ActivityIndicator: View {
    let size: CGFloat
    let color: Color
    let lineWidth: CGFloat
    let style: ActivityIndicatorStyle
    
    @State private var isAnimating = false
    
    enum ActivityIndicatorStyle {
        case circular
        case dots
        case bars
        case pulse
    }
    
    init(
        size: CGFloat = 30,
        color: Color = .white,
        lineWidth: CGFloat = 3,
        style: ActivityIndicatorStyle = .circular
    ) {
        self.size = size
        self.color = color
        self.lineWidth = lineWidth
        self.style = style
    }
    
    var body: some View {
        Group {
            switch style {
            case .circular:
                circularIndicator
            case .dots:
                dotsIndicator
            case .bars:
                barsIndicator
            case .pulse:
                pulseIndicator
            }
        }
        .onAppear {
            isAnimating = true
        }
        .onDisappear {
            isAnimating = false
        }
    }
    
    // MARK: - Circular Spinner
    private var circularIndicator: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .frame(width: size, height: size)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
    }
    
    // MARK: - Dots Indicator
    private var dotsIndicator: some View {
        HStack(spacing: size * 0.1) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(color)
                    .frame(width: size * 0.2, height: size * 0.2)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .opacity(isAnimating ? 1.0 : 0.3)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
    }
    
    // MARK: - Bars Indicator
    private var barsIndicator: some View {
        HStack(spacing: size * 0.05) {
            ForEach(0..<5, id: \.self) { index in
                RoundedRectangle(cornerRadius: size * 0.05)
                    .fill(color)
                    .frame(width: size * 0.15, height: size)
                    .scaleEffect(y: isAnimating ? 1.0 : 0.3)
                    .animation(
                        .easeInOut(duration: 0.8)
                        .repeatForever()
                        .delay(Double(index) * 0.1),
                        value: isAnimating
                    )
            }
        }
    }
    
    // MARK: - Pulse Indicator
    private var pulseIndicator: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(color.opacity(0.4), lineWidth: lineWidth)
                    .frame(width: size, height: size)
                    .scaleEffect(isAnimating ? 1.0 : 0.3)
                    .opacity(isAnimating ? 0.0 : 1.0)
                    .animation(
                        .easeInOut(duration: 1.2)
                        .repeatForever()
                        .delay(Double(index) * 0.4),
                        value: isAnimating
                    )
            }
        }
    }
}

// MARK: - Convenience Initializers
extension ActivityIndicator {
    // Light theme
    static func light(size: CGFloat = 30, style: ActivityIndicatorStyle = .circular) -> ActivityIndicator {
        ActivityIndicator(size: size, color: .white, style: style)
    }
    
    // Dark theme
    static func dark(size: CGFloat = 30, style: ActivityIndicatorStyle = .circular) -> ActivityIndicator {
        ActivityIndicator(size: size, color: .black, style: style)
    }
    
    // Primary color
    static func primary(size: CGFloat = 30, style: ActivityIndicatorStyle = .circular) -> ActivityIndicator {
        ActivityIndicator(size: size, color: .blue, style: style)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 50) {
            // Circular Indicators
            VStack(spacing: 20) {
                Text("Circular Indicators")
                    .foregroundColor(.white)
                    .font(.headline)
                
                HStack(spacing: 30) {
                    ActivityIndicator.light(size: 30, style: .circular)
                    ActivityIndicator(size: 40, color: .blue, style: .circular)
                    ActivityIndicator(size: 50, color: .green, style: .circular)
                }
            }
            
            // Dots Indicators
            VStack(spacing: 20) {
                Text("Dots Indicators")
                    .foregroundColor(.white)
                    .font(.headline)
                
                HStack(spacing: 30) {
                    ActivityIndicator.light(size: 30, style: .dots)
                    ActivityIndicator(size: 40, color: .blue, style: .dots)
                    ActivityIndicator(size: 50, color: .green, style: .dots)
                }
            }
            
            // Bars Indicators
            VStack(spacing: 20) {
                Text("Bars Indicators")
                    .foregroundColor(.white)
                    .font(.headline)
                
                HStack(spacing: 30) {
                    ActivityIndicator.light(size: 30, style: .bars)
                    ActivityIndicator(size: 40, color: .blue, style: .bars)
                    ActivityIndicator(size: 50, color: .green, style: .bars)
                }
            }
            
            // Pulse Indicators
            VStack(spacing: 20) {
                Text("Pulse Indicators")
                    .foregroundColor(.white)
                    .font(.headline)
                
                HStack(spacing: 30) {
                    ActivityIndicator.light(size: 30, style: .pulse)
                    ActivityIndicator(size: 40, color: .blue, style: .pulse)
                    ActivityIndicator(size: 50, color: .green, style: .pulse)
                }
            }
        }
        .padding(40)
    }
    .background(Color.black)
}
