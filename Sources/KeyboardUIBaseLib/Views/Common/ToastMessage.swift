//
//  ToastMessage.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 27/8/25.
//

import SwiftUI

// MARK: - Custom Animation Extensions
extension Animation {
    static func toastEaseIn() -> Animation {
        .easeIn(duration: 0.4)
    }
    
    static func toastEaseOut() -> Animation {
        .easeOut(duration: 0.15)
    }
}

struct ToastMessage: View {
    // MARK: - Properties
    private let message: String
    private let type: ToastType
    internal let duration: Double  // Made internal for SimpleToastManager access
    
    enum ToastType {
        case success
        case error
        case warning
        case info
        case `default`
        
        var backgroundColor: Color {
            switch self {
            case .success: return Color(hex: "#34C759")
            case .error: return Color(hex: "#FF3B30")
            case .warning: return Color(hex: "#FF9500")
            case .info: return Color(hex: "#007AFF")
            case .default: return Color.white
            }
        }
        
        var textColor: Color {
            switch self {
            case .default: return Color.black
            default : return Color.white
            }
        }
    }
    
    // MARK: - Initializer
    init(_ message: String, type: ToastType = .default, duration: Double = 1.5) {
        self.message = message
        self.type = type
        self.duration = duration
    }
    
    var body: some View {
        WText(message)
            .customFont(.interMedium, size: 13)
            .lineLimit(1)
            .foregroundColor(type.textColor)
        .padding(.horizontal, 22)
        .padding(.vertical, 9)
        .background(
            RoundedRectangle(cornerRadius: 112)
                .fill(type.backgroundColor)
                .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 0)
        )
    }
}

// MARK: - Factory Methods
extension ToastMessage {
    static func success(_ message: String) -> ToastMessage {
        ToastMessage(message, type: .success)
    }
    
    static func error(_ message: String) -> ToastMessage {
        ToastMessage(message, type: .error)
    }
    
    static func warning(_ message: String) -> ToastMessage {
        ToastMessage(message, type: .warning)
    }
    
    static func info(_ message: String) -> ToastMessage {
        ToastMessage(message, type: .info)
    }
}

// MARK: - Simple Toast Manager
@MainActor
class ToastMessageManager: ObservableObject {
    @Published var currentToast: ToastMessage?
    @Published var isVisible = false
    
    private var timer: Timer?
    
    func show(_ toast: ToastMessage) {
        // Cancel existing timer
        timer?.invalidate()
        
        // If there's already a toast, hide it immediately
        if isVisible {
            isVisible = false
            currentToast = nil
        }
        
        // Show new toast with ease-in animation
        currentToast = toast
        withAnimation(.toastEaseIn()) {
            isVisible = true
        }
        
        // Auto hide after duration
        timer = Timer.scheduledTimer(withTimeInterval: toast.duration, repeats: false) { _ in
            Task { @MainActor in
                self.hide()
            }
        }
    }
    
    func hide() {
        timer?.invalidate()
        
        // Hide with ease-out animation
        withAnimation(.toastEaseOut()) {
            isVisible = false
        }
        
        // Clear toast after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.currentToast = nil
        }
    }
    
    // Convenience methods
    func showSuccess(_ message: String) {
        show(ToastMessage.success(message))
    }
    
    func showError(_ message: String) {
        show(ToastMessage.error(message))
    }
    
    func showWarning(_ message: String) {
        show(ToastMessage.warning(message))
    }
    
    func showInfo(_ message: String) {
        show(ToastMessage.info(message))
    }
}

// MARK: - Preview
#Preview {
    struct ToastPreview: View {
        @StateObject private var toastManager = ToastMessageManager()
        
        var body: some View {
            VStack(spacing: 30) {
                Text("Simple Toast Messages")
                    .font(.title)
                    .padding(.top)
                
                // Static examples
                VStack(spacing: 16) {
                    Text("Static Examples:")
                        .font(.headline)
                    
                    ToastMessage.success("Operation completed!")
                    ToastMessage.error("Something went wrong!")
                    ToastMessage.warning("Please check this")
                    ToastMessage.info("New notification")
                }
                
                Spacer()
                
                // Interactive buttons
                VStack(spacing: 15) {
                    Text("Interactive Examples:")
                        .font(.headline)
                    
                    Button("Show Success") {
                        toastManager.showSuccess("Great! Everything worked perfectly.")
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Show Error") {
                        toastManager.showError("Oops! Something went wrong.")
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Show Warning") {
                        toastManager.showWarning("Please check your connection.")
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Show Info") {
                        toastManager.showInfo("Here's some useful information.")
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
            }
            .padding()
            .displayToastMessage(toastManager)
        }
    }
    
    return ToastPreview()
}

