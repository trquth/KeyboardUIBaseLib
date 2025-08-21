
//
//  CustomKeyboardView.swift
//  BaseKeyboard
//
//  Created by Thien Tran-Quan on 11/8/25.
//

import SwiftUI

struct CustomKeyboardV2View: View {
    @State private var isShiftActive = false
    @State private var isCapsLockActive = false
    @State private var currentKeyboardMode: KeyboardLayout.LayoutType = .letters
    @State private var lastShiftTapTime: Date = Date()
    
    // Callback for key presses
    let onKeyPressed: ((String, KeyboardLayout.SpecialKey?) -> Void)?
    
    init(onKeyPressed: ((String, KeyboardLayout.SpecialKey?) -> Void)? = nil) {
        self.onKeyPressed = onKeyPressed
    }
    
    // Current layout based on mode
    private var currentLayout: [[String]] {
        KeyboardLayout.getLayout(for: currentKeyboardMode)
    }
    
    private func textKeyButton(_ key: String) -> some View {
        let size = KeyboardLayout.getKeySize(for: key, in: 0)
        let displayText = getDisplayText(for: key)
        
        return TextKeyboardButton(
            text: displayText, 
            width: size.width, 
            height: size.height
        ) {
            handleKeyPress(key)
        }
    }
    
    // Get the display text for a key based on shift state
    private func getDisplayText(for key: String) -> String {
        if isCapsLockActive || isShiftActive {
            return key.uppercased()
        }
        return key.lowercased()
    }
    
    private func handleShift() {
        let currentTime = Date()
        let timeDifference = currentTime.timeIntervalSince(lastShiftTapTime)
        
        // Double tap within 0.3 seconds toggles caps lock
        if timeDifference < 0.3 {
            isCapsLockActive.toggle()
            isShiftActive = false
        } else {
            // Single tap toggles shift
            if isCapsLockActive {
                // If caps lock is on, turn it off with single tap
                isCapsLockActive = false
            } else {
                isShiftActive.toggle()
            }
        }
        
        lastShiftTapTime = currentTime
    }
    
    private func actionKeyButton(_ key: String) -> some View {
        let size = KeyboardLayout.getKeySize(for: key, in: 0)
        return TextKeyboardButton(
            text: key,
            width: size.width,
            height: size.height,
            titleFontSize: 16,
            buttonStyle: .minimal
        ) {
            handleKeyPress(key)
        }
    }
    
    private func handleKeyPress(_ key: String) {
        let specialKey = KeyboardLayout.getSpecialKey(for: key)
        
        // For text keys, determine the actual character to send based on shift state
        let actualKey: String
        if specialKey == nil && currentKeyboardMode == .letters {
            actualKey = (isCapsLockActive || isShiftActive) ? key.uppercased() : key.lowercased()
            // Auto-disable shift after typing a letter (single shift behavior, but not caps lock)
            if isShiftActive && !isCapsLockActive {
                isShiftActive = false
            }
        } else {
            actualKey = key
        }
        
        // Always call the callback with the actual character
        onKeyPressed?(actualKey, specialKey)
        
        // Handle special key actions
        guard let specialKey = specialKey else { 
            // Regular text key
            print("Text key pressed: \(actualKey)")
            return 
        }
        
        switch specialKey {
        case .numbers:
            currentKeyboardMode = .numbers
            isShiftActive = false // Reset shift when changing modes
            isCapsLockActive = false // Reset caps lock when changing modes
            print("Switched to numbers mode")
        case .symbols:
            currentKeyboardMode = .symbols
            isShiftActive = false // Reset shift when changing modes
            isCapsLockActive = false // Reset caps lock when changing modes
            print("Switched to symbols mode")
        case .letters:
            currentKeyboardMode = .letters
            print("Switched to letters mode")
        case .shift:
            handleShift()
            print("Shift handled - isShift: \(isShiftActive), isCapsLock: \(isCapsLockActive)")
        case .delete:
            print("Delete pressed")
        case .enter:
            print("Enter pressed")
            // Reset single shift on new line (but not caps lock)
            if isShiftActive && !isCapsLockActive {
                isShiftActive = false
            }
        case .globe:
            print("Globe pressed")
        case .space:
            print("Space pressed")
            // Reset single shift after space (but not caps lock)
            if isShiftActive && !isCapsLockActive {
                isShiftActive = false
            }
        case .dot:
            print("Dot pressed")
        case .emoji:
            print("Emoji pressed")
        }
    }
    
    private func iconKeyButton(
        asset: AssetIconEnum,
        key: String
    ) -> some View {
        print("Creating icon button for key: \(key) with asset: \(asset)")
        let size = KeyboardLayout.getKeySize(for: key, in: 0)
        let iconSize = getIconSize(for: asset)
        let isShiftKey = key == KeyboardLayout.SpecialKey.shift.rawValue
        
        return IconKeyboardButton(
            assetName: asset.fileName,
            width: size.width,
            height: size.height,
            iconSize: iconSize
        ) {
            handleKeyPress(key)
        }
    }
    
    private func getIconSize(for asset: AssetIconEnum) -> CGSize {
        switch asset {
        case .upperCase:
            return CGSize(width: 17, height: 15.38)
        case .delete:
            return CGSize(width: 22.17, height: 17.62)
        case .emoji:
            return CGSize(width: 18.99, height: 18.99)
        case .enter:
            return CGSize(width: 23.73, height: 19.93)
        default:
            return CGSize(width: 20, height: 20)
        }
    }
    
    private func spaceButton() -> some View {
        let size = KeyboardLayout.getKeySize(for: "space", in: 3)
        return TextKeyboardButton(
            text: "space",
            width: size.width,
            height: size.height,
            titleFontSize: 18
        ) {
            handleKeyPress("space")
        }
    }
    
    @ViewBuilder
    private func keyButton(for key: String, in row: Int) -> some View {
        if KeyboardLayout.isSpecialKey(key) {
            switch key {
            case KeyboardLayout.SpecialKey.space.rawValue:
                spaceButton()
            case KeyboardLayout.SpecialKey.shift.rawValue:
                iconKeyButton(asset: .upperCase, key: key)
            case KeyboardLayout.SpecialKey.delete.rawValue:
                iconKeyButton(asset: .delete, key: key)
            case KeyboardLayout.SpecialKey.numbers.rawValue,
                KeyboardLayout.SpecialKey.symbols.displayText,
                KeyboardLayout.SpecialKey.dot.rawValue:
                actionKeyButton(key)
            case KeyboardLayout.SpecialKey.globe.rawValue:
                iconKeyButton(asset: .emoji, key: key)
            case KeyboardLayout.SpecialKey.emoji.rawValue:
                iconKeyButton(asset: .emoji, key: key)
            case KeyboardLayout.SpecialKey.enter.rawValue:
                iconKeyButton(asset: .enter, key: key)
            case KeyboardLayout.SpecialKey.letters.rawValue:
                actionKeyButton(key)
            default:
                textKeyButton(key)
            }
        } else {
            textKeyButton(key)
        }
    }
    

    var body: some View {
        VStack(spacing: 12.4) {
            ForEach(0..<currentLayout.count, id: \.self) { rowIndex in
                HStack(spacing: 6.4) {
                    ForEach(currentLayout[rowIndex], id: \.self) { key in
                        keyButton(for: key, in: rowIndex)
                    }
                }
                .frame(height: 44, alignment: .center)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.bottom, 10)
        .padding(.top,8)
        .animation(.easeInOut(duration: 0.2), value: currentKeyboardMode)
    }
}


#Preview("Custom Keyboard - Letters") {
    CustomKeyboardV2View()
        .border(.black, width: 1)
}

#Preview("Custom Keyboard - With Callback") {
    VStack(spacing: 20) {
        Text("Keyboard with Callback")
            .font(.headline)
        
        CustomKeyboardV2View { key, specialKey in
            if let specialKey = specialKey {
                print("🎯 Special key pressed: \(key) -> \(specialKey)")
            } else {
                print("📝 Text key pressed: \(key)")
            }
        }
    }
    .padding()
}

#Preview("Custom Keyboard - All Modes") {
    VStack(spacing: 20) {
        Text("Letters Mode")
            .font(.headline)
        CustomKeyboardV2View { key, specialKey in
            print("Key pressed: \(key)")
        }
        
        Text("Numbers Mode")
            .font(.headline)
        CustomKeyboardV2View { key, specialKey in
            print("Key pressed: \(key)")
        }
            .onAppear {
                // This won't work in preview, but shows the concept
            }
        
        Text("Symbols Mode")
            .font(.headline) 
        CustomKeyboardV2View { key, specialKey in
            print("Key pressed: \(key)")
        }
    }
    .padding()
}

