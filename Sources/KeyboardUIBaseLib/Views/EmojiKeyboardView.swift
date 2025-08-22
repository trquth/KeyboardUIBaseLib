//
//  EmojiKeyboardView.swift
//  KeyboardBaseIOS
//
//  Created by Thien Tran-Quan on 18/8/25.
//

import SwiftUI

struct EmojiKeyboardView: View {
    // Callback for emoji selection
    let onEmojiSelected: ((String) -> Void)?
    let onBackToKeyboard: (() -> Void)?
    
    @State private var selectedCategory: EmojiCategory = .recent
    @State private var recentEmojis: [String] = [] // Start empty to show placeholder
    
    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 8)
    
    init(
        onEmojiSelected: ((String) -> Void)? = nil,
        onBackToKeyboard: (() -> Void)? = nil
    ) {
        self.onEmojiSelected = onEmojiSelected
        self.onBackToKeyboard = onBackToKeyboard
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedCategory) {
                ForEach(EmojiCategory.allCases, id: \.self) { category in
                    ScrollView {
                        LazyVGrid(columns: gridColumns, spacing: 8) {
                            ForEach(category == .recent ? displayedRecentEmojis : category.emojis, id: \.self) { emoji in
                                emojiButton(emoji)
                            }
                        }
                        .padding(.horizontal, 8)
                       .padding(.top, 8)
                       .padding(.bottom, 5)
                    }
                    .background(.white)
                    .tag(category)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))        
            categorySection()
        }
    }
    
    private func categorySection() -> some View {
        categorySelector()
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(Color(hex: "#F3F4F6"))    
    }
    
    private func categorySelector() -> some View {
        HStack(spacing: 4) {
            backToKeyboardButton()
            
            ForEach(EmojiCategory.allCases, id: \.self) { category in
                categoryButton(category)
            }
            
            deleteButton()
        }
    }
    
    private func backToKeyboardButton() -> some View {
        WTextButton("ABC") {
            onBackToKeyboard?()
        }
        .buttonStyle(.minimal)
        .buttonSize(width: 36, height: 36)
        .font(.custom(.interRegular, size: 14))
        .backgroundColor(.white)
        .foregroundColor(.primary)
        .cornerRadius(8)
    }
    
    private func deleteButton() -> some View {
        WIconButton("delete_ico") {
            // Simulate delete key press - this would need to be handled by the parent
            onEmojiSelected?("⌫") // Using backspace character
        }
        .buttonStyle(.minimal)
        .buttonSize(width: 40, height: 36)
        .backgroundColor(.white)
        .foregroundColor(.primary)
        .cornerRadius(8)
    }
    
    private func categoryButton(_ category: EmojiCategory) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedCategory = category
            }
        }) {
            Text(category.icon)
                .font(.system(size: 14))
                .frame(height: 25)
                .frame(maxWidth: .infinity)
                .background(
                    Circle()
                        .fill(selectedCategory == category ? Color.blue.opacity(0.2) : Color.clear)
                )
                .overlay(
                    Circle()
                        .stroke(selectedCategory == category ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 1)
                )
                .scaleEffect(selectedCategory == category ? 1.1 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func categoryIndicatorBackground() -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.blue.opacity(0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
    }
    
    private var displayedEmojis: [String] {
        if selectedCategory == .recent {
            return displayedRecentEmojis
        }
        return selectedCategory.emojis
    }
    
    private var displayedRecentEmojis: [String] {
        return recentEmojis.isEmpty ? ["🎉", "👋", "😊", "❤️", "👍", "😂", "🔥", "💯"] : recentEmojis
    }
    
    private func emojiButton(_ emoji: String) -> some View {
        Button(action: {
            selectEmoji(emoji)
        }) {
            Text(emoji)
                .font(.system(size: 22))
                .frame(width: 38, height: 38)
                .background(Color.clear)
                .contentShape(Rectangle())
        }
        .buttonStyle(EmojiButtonStyle())
    }
    
    private func selectEmoji(_ emoji: String) {
        // Add to recent emojis (avoid duplicates and limit to 16)
        recentEmojis.removeAll { $0 == emoji }
        recentEmojis.insert(emoji, at: 0)
        recentEmojis = Array(recentEmojis.prefix(16))
        
        // Provide haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Call the callback
        onEmojiSelected?(emoji)
    }
}

// MARK: - Custom Button Style for Emoji Selection
struct EmojiButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.2 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    EmojiKeyboardView(
        onEmojiSelected: { emoji in
            print("Selected emoji: \(emoji)")
        },
        onBackToKeyboard: {
            print("Back to keyboard")
        }
    ).frame(height:KeyboardConfiguration.KEYBOARD_HEIGHT)
        .border(.yellow, width: 1)
}
