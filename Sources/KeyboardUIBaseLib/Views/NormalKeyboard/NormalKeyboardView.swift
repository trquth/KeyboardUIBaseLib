
//
//  CustomKeyboardView.swift
//  BaseKeyboard
//
//  Created by Thien Tran-Quan on 11/8/25.
//

import SwiftUI

typealias KeyPressCallback = (String) -> Void

struct NormalKeyboardView: View {
    @State private var shiftState: ShiftState = .off
    @State private var currentKeyboardMode: KeyboardLayout.LayoutType = .letters
    @State private var lastShiftTapTime: Date = Date()
    @State private var lastSpaceTapTime: Date = Date()
    @State private var calculatedKeyItems: [KeyItem] = []
    @State private var containerWidth: CGFloat = 0
    @State private var shouldAutoCapitalize = true // Auto capitalization state
    @Binding var currentText: String
    
    // Auto-capitalization control
    private let isAutoCapitalizationEnabled: Bool
    
    // Double tap space control
    private let isDoubleTapSpaceEnabled: Bool
    
    private enum ShiftState {
        case on, off, capsLock
    }
    
    // Callback for key presses
    let onKeyPressed: ((String) -> Void)?
    
    // Keyboard layout constants
    private let standardKeyHeight: CGFloat = 44
    private let rowSpacing: CGFloat = 12.4
    private let keySpacing: CGFloat = 4.0 // Reduced spacing for better full-width usage
    private let keyboardPadding: CGFloat = 0 // Use full width - no padding
    
    init(
        currentText: Binding<String>, 
        isAutoCapitalizationEnabled: Bool = true,
        isDoubleTapSpaceEnabled: Bool = true,
        onKeyPressed: ((String) -> Void)? = nil
    ) {
        self._currentText = currentText
        self.isAutoCapitalizationEnabled = isAutoCapitalizationEnabled
        self.isDoubleTapSpaceEnabled = isDoubleTapSpaceEnabled
        self.onKeyPressed = onKeyPressed
    }
    
    private func getKeyType(for key: String) -> KeyItem.KeyType {
        guard let specialKey = KeyboardLayout.getSpecialKey(for: key) else {
            return .text
        }
        
        switch specialKey {
        case .space:
            return .space
        case .shift, .delete, .emoji, .enter:
            return .icon
        case .numbers, .symbols, .letters, .dot:
            return .action
        default:
            return .text
        }
    }
    
    // Current layout based on mode
    private var currentLayout: [[String]] {
        KeyboardLayout.getLayout(for: currentKeyboardMode)
    }
    
    // Get the display text for a key based on shift state
    private func getDisplayText(for key: String) -> String {
        // Show uppercase if shift is active OR if auto-capitalization should happen (when enabled)
        if shiftState != .off || (isAutoCapitalizationEnabled && shouldAutoCapitalizeNext()) {
            return key.uppercased()
        }
        return key.lowercased()
    }
    
    // MARK: - Key Handling Methods
    
    private func handleCharacterKey(_ key: String) -> String {
        let actualKey: String
        if currentKeyboardMode == .letters {
            // Check if we should capitalize based on shift state or auto capitalization (when enabled)
            
            if getKeyType(for: key) == .text {
                let shouldCapitalize = shiftState != .off || (isAutoCapitalizationEnabled && shouldAutoCapitalizeNext())
                actualKey = shouldCapitalize ? key.uppercased() : key.lowercased()
            }else {
                actualKey = key
            }
            
            // Auto-disable shift after typing a letter (single shift behavior, but not caps lock)
            if shiftState == .on {
                shiftState = .off
            }
            
            // Update auto capitalization state after typing (only if auto-capitalization is enabled)
            if isAutoCapitalizationEnabled {
                updateAutoCapitalizationStateAfterTyping(actualKey)
            }
        } else {
            actualKey = key
        }
        
        onKeyPressed?(actualKey)
        return actualKey
    }
    
    
    private func handleShiftKey() {
        handleShift() // Use existing shift logic
    }
    
    private func switchToNumbersMode() {
        currentKeyboardMode = .numbers
        shiftState = .off
        LogUtil.d(.NORMAL_KEYBOARD_VIEW, "Switched to numbers mode")
    }
    
    private func switchToLettersMode() {
        currentKeyboardMode = .letters
        LogUtil.d(.NORMAL_KEYBOARD_VIEW, "Switched to letters mode")
    }
    
    private func switchToSymbolsMode() {
        currentKeyboardMode = .symbols
        shiftState = .off
        LogUtil.d(.NORMAL_KEYBOARD_VIEW, "Switched to symbols mode")
    }
    
    private func handleDeleteKey() {
        handleKeyPress(KeyboardLayout.SpecialKey.delete.rawValue)
        LogUtil.d(.NORMAL_KEYBOARD_VIEW, "Delete key pressed")
    }
    
    private func handleEnterKey(){
        if shiftState == .on {
            shiftState = .off
        }
        handleKeyPress(KeyboardLayout.SpecialKey.enter.rawValue)
        LogUtil.d(.NORMAL_KEYBOARD_VIEW, "Enter key pressed")
    }
    
    private func handleKeyPress(_ key: String) {
        // Always call the callback with the actual character
        _ = handleCharacterKey(key)
    }
    
    private func renderSpaceButton(_ keyItem: KeyItem) -> some View {
        TextKeyboardButton(
            text: KeyboardLayout.SpecialKey.space.keyDisplay,
            width: keyItem.frame.width,
            height: keyItem.frame.height,
            titleFontSize: 18
            
        ) {
            handleSpaceKey()
        }
    }
    
    private func renderIconKeyButton(_ keyItem: KeyItem,withAsset asset: AssetIconEnum, action: KeyPressCallback? = nil) -> some View {
        IconKeyboardButton(
            assetName: asset.rawValue,
            width: keyItem.frame.width,
            height: keyItem.frame.height,
            foregroundColor:.black
        ) {
            action?(keyItem.key)
        }
    }
    
    private func renderIconKeyButton(_ keyItem: KeyItem,withAsset asset: AssetIconEnum, isActive: Bool,action: KeyPressCallback? = nil) -> some View {
        IconKeyboardButton(
            assetName: asset.rawValue,
            width: keyItem.frame.width,
            height: keyItem.frame.height,
            foregroundColor: .black,
            backgroundColor: isActive ? Color(hex: "#E8E8E8") : nil
        ) {
            action?(keyItem.key)
        }
    }
    
    
    private func renderTextKeyButton(_ keyItem: KeyItem, withTitle title: String = "", action: KeyPressCallback? = nil) -> some View {
        TextKeyboardButton(
            text: title.isEmpty ? getDisplayText(for: keyItem.key) : title,
            width: keyItem.frame.width,
            height: keyItem.frame.height
        ) {
            action?(keyItem.key)
        }
    }
    
    private func renderActionKeyButton(_ keyItem: KeyItem, withTitle title: String = "", action: KeyPressCallback? = nil) -> some View {
        return TextKeyboardButton(
            text: title.isEmpty ? keyItem.displayText : title,
            width: keyItem.frame.width,
            height: keyItem.frame.height,
            titleFontSize: 16,
            buttonStyle: .minimal
        ) {
            action?(keyItem.key)
        }
    }
    
    private func renderShiftKeyButton(_ keyItem: KeyItem) -> some View {
        // Show active state when: manual shift is on, caps lock is active, or auto-capitalization should happen (when enabled)
        let isActive = shiftState != .off || (isAutoCapitalizationEnabled && shouldAutoCapitalize && currentKeyboardMode == .letters)
        let isCapsLock = shiftState == .capsLock
        
        return IconKeyboardButton(
            assetName: AssetIconEnum.upperCase.rawValue,
            width: keyItem.frame.width,
            height: keyItem.frame.height,
            foregroundColor: .black,
            backgroundColor: isActive ? Color(hex: "#E8E8E8") : nil
        ) {
            handleShift()
        }
        .opacity(isCapsLock ? 0.9 : 1.0) // Slightly dimmed for caps lock
        .overlay(
            // Add a small indicator for caps lock
            Group {
                if isCapsLock {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 4, height: 4)
                        .offset(x: keyItem.frame.width/2 - 8, y: -keyItem.frame.height/2 + 8)
                }
            }
        )
    }
    
    @ViewBuilder
    private func renderKey(for keyItem: KeyItem) -> some View {
        if keyItem.isSpecial {
            // Handle special keys
            if let specialKey = KeyboardLayout.getSpecialKey(for: keyItem.key) {
                switch specialKey {
                case .space:
                    renderSpaceButton(keyItem)
                case .shift:
                    renderShiftKeyButton(keyItem)
                case .delete:
                    renderIconKeyButton(keyItem, withAsset: .delete) { _ in
                        handleDeleteKey()
                    }
                case .enter:
                    renderIconKeyButton(keyItem, withAsset: .enter){ _ in
                        handleEnterKey()
                    }
                case .numbers:
                    renderActionKeyButton(keyItem, withTitle: "?123"){ _ in
                        switchToNumbersMode()
                    }
                case .letters:
                    renderActionKeyButton(keyItem, withTitle: "ABC"){_ in
                        switchToLettersMode()
                    }
                case .symbols:
                    renderActionKeyButton(keyItem, withTitle: "#+"){ _ in
                        switchToSymbolsMode()
                    }
                case .dot:
                    switch currentKeyboardMode {
                    case .numbers, .symbols:
                        renderTextKeyButton(keyItem, withTitle: "."){ _ in
                            handleKeyPress(".")
                        }
                    default:
                        renderActionKeyButton(keyItem, withTitle: "."){_ in 
                            handleKeyPress(".")
                        }
                    }
                case .globe, .emoji:
                    renderIconKeyButton(keyItem, withAsset: .emoji){_ in handleKeyPress(KeyboardLayout.SpecialKey.emoji.rawValue)
                    }
                }
            } else {
                renderTextKeyButton(keyItem){ key in
                    handleKeyPress(key)
                }
            }
        } else {
            renderTextKeyButton(keyItem){ key in
                handleKeyPress(key)
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Calculate key items when geometry changes
                Color.clear
                    .onAppear {
                        recalculateKeyItems(for: geometry.size.width)
                        // Initialize auto capitalization based on current text
                        _ = updateAutoCapitalizationStateFromText()
                    }
                    .onChangeCompact(of: geometry.size.width) { newWidth in
                        recalculateKeyItems(for: newWidth)
                    }
                
                // Render keys using calculated positions
                ForEach(calculatedKeyItems, id: \.key) { keyItem in
                    renderKey(for: keyItem)
                        .frame(width: keyItem.frame.width, height: keyItem.frame.height)
                        .position(
                            x: keyItem.frame.midX,
                            y: keyItem.frame.midY
                        )                }.onChangeCompact(of: currentKeyboardMode, perform: { _ in
                            LogUtil.d(.NORMAL_KEYBOARD_VIEW, "Keyboard mode changed to \(currentKeyboardMode), recalculating keys")
                            
                            recalculateKeyItems(for: geometry.size.width)
                        })
                        .onChangeCompact(of: currentText, perform: { _ in
                            // Only handle auto-capitalization if it's enabled
                            guard isAutoCapitalizationEnabled else { return }
                            
                            let status = updateAutoCapitalizationStateFromText()
                            LogUtil.d(.NORMAL_KEYBOARD_VIEW, "Text changed: '\(currentText)', shouldAutoCapitalize = \(status), autoCapEnabled = \(isAutoCapitalizationEnabled)")
                            
                            // Update shift state based on auto-capitalization when text is empty
                            if currentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && status {
                                // Only set shift to .on if user hasn't manually set caps lock
                                if shiftState != .capsLock {
                                    shiftState = .on
                                    LogUtil.d(.NORMAL_KEYBOARD_VIEW, "Empty text detected - enabling shift for auto-capitalization")
                                }
                            } else if !status && shiftState == .on {
                                // Reset shift if auto-capitalization is no longer needed and it was auto-set
                                shiftState = .off
                                LogUtil.d(.NORMAL_KEYBOARD_VIEW, "Auto-capitalization no longer needed - disabling shift")
                            }
                        })
            }
        }
        .frame(height: calculateKeyboardHeight())
    }
}

//MARK: - Double Tap Space to insert Period
extension NormalKeyboardView {
    private func handleSpaceKey() {
        let currentTime = Date()
        let timeDifference = currentTime.timeIntervalSince(lastSpaceTapTime)
        
        // Check if double tap space feature is enabled and detect double tap within 0.3 seconds
        if isDoubleTapSpaceEnabled && timeDifference < 0.3 {
            // Replace the last space with period + space
            onKeyPressed?(KeyboardLayout.SpecialKey.delete.rawValue) // Remove last space
            onKeyPressed?(".") // Insert period
            onKeyPressed?(KeyboardLayout.SpecialKey.space.rawValue) // Insert space
            LogUtil.d(.NORMAL_KEYBOARD_VIEW, "Double space detected - inserted period")
        } else {
            // Single space tap or double tap feature disabled
            if shiftState == .on {
                shiftState = .off
            }
            onKeyPressed?(KeyboardLayout.SpecialKey.space.rawValue)
            LogUtil.d(.NORMAL_KEYBOARD_VIEW, "Single space pressed")
        }
        
        lastSpaceTapTime = currentTime
    }
    
}

//MARK: - Shift and Caps Lock Logic
extension NormalKeyboardView {
    private func handleShift() {
        let currentTime = Date()
        let timeDifference = currentTime.timeIntervalSince(lastShiftTapTime)
        
        // Double tap within 0.3 seconds toggles caps lock
        if timeDifference < 0.3 {
            switch shiftState {
            case .off, .on:
                shiftState = .capsLock
                LogUtil.d(.NORMAL_KEYBOARD_VIEW, "Double tap detected - Caps Lock: ON")
            case .capsLock:
                shiftState = .off
                LogUtil.d(.NORMAL_KEYBOARD_VIEW, "Double tap detected - Caps Lock: OFF")
            }
        } else {
            // Single tap cycles through states
            switch shiftState {
            case .off:
                shiftState = .on
                LogUtil.d(.NORMAL_KEYBOARD_VIEW, "Shift: ON")
            case .on:
                shiftState = .off
                LogUtil.d(.NORMAL_KEYBOARD_VIEW, "Shift: OFF")
            case .capsLock:
                shiftState = .off
                shouldAutoCapitalize = false
                LogUtil.d(.NORMAL_KEYBOARD_VIEW, "Caps Lock disabled by single tap")
            }
        }
        
        // When user manually activates shift/caps, disable auto capitalization for that character
        if shiftState != .off {
            shouldAutoCapitalize = false
        }
        
        lastShiftTapTime = currentTime
    }
}

//MARK: - Auto-Capitalization Logic
extension NormalKeyboardView {
    /// Returns true if any form of shift is active (on or caps lock)
    private var isShiftActive: Bool {
        return shiftState != .off
    }
    
    /// Returns true if caps lock is specifically active
    private var isCapsLockActive: Bool {
        return shiftState == .capsLock
    }
    
    /// Returns true if single shift is active (not caps lock)
    private var isSingleShiftActive: Bool {
        return shiftState == .on
    }
    
    // MARK: - Auto Capitalization Logic
    
    private func shouldAutoCapitalizeNext() -> Bool {
        return shouldAutoCapitalize
    }
    
    private func updateAutoCapitalizationStateFromText() -> Bool {
        // If auto-capitalization is disabled, always return false
        guard isAutoCapitalizationEnabled else {
            shouldAutoCapitalize = false
            LogUtil.v(LogTagEnum.NORMAL_KEYBOARD_VIEW, "Auto-capitalization disabled - shouldAutoCapitalize = false")
            return false
        }
        
        let trimmedText = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedText.isEmpty {
            // Beginning of text - should auto capitalize
            shouldAutoCapitalize = true
            LogUtil.v(LogTagEnum.NORMAL_KEYBOARD_VIEW, "Text is empty - auto capitalization enabled")
        } else {
            // Check if we're after a sentence ending followed by space(s)
            let sentenceEnders: Set<Character> = [".", "!", "?"]
            let words = trimmedText.components(separatedBy: .whitespaces)
            
            if let lastWord = words.last, !lastWord.isEmpty {
                // Check if the original text ends with whitespace after a sentence ender
                if currentText.hasSuffix(" ") || currentText.hasSuffix("\t") || currentText.hasSuffix("\n") {
                    if let lastChar = lastWord.last, sentenceEnders.contains(lastChar) {
                        shouldAutoCapitalize = true
                        LogUtil.v(LogTagEnum.NORMAL_KEYBOARD_VIEW, "After sentence ender + space - auto capitalization enabled")
                    } else {
                        shouldAutoCapitalize = false
                    }
                } else {
                    // In the middle of a word
                    shouldAutoCapitalize = false
                }
            } else {
                // Only whitespace at the end
                shouldAutoCapitalize = true
                LogUtil.v(LogTagEnum.NORMAL_KEYBOARD_VIEW, "Only whitespace - auto capitalization enabled")
            }
        }
        
        LogUtil.v(LogTagEnum.NORMAL_KEYBOARD_VIEW, "Auto capitalization updated: shouldAutoCapitalize = \(shouldAutoCapitalize), shiftState = \(shiftState), text: '\(currentText)'")
        
        return shouldAutoCapitalize
    }
    
    /// Update auto capitalization state after typing a character
    /// This helps maintain proper capitalization flow
    private func updateAutoCapitalizationStateAfterTyping(_ typedKey: String) {
        // Check if text became empty after typing (e.g., after delete operations)
        let isTextEmpty = currentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        if isTextEmpty {
            // Text is empty - enable auto-capitalization for next character
            shouldAutoCapitalize = true
            LogUtil.v(LogTagEnum.NORMAL_KEYBOARD_VIEW, "Text is empty after typing - enabling auto capitalization")
            return
        }
        
        // If we just typed a sentence ender, prepare for next capitalization
        let sentenceEnders: Set<Character> = [".", "!", "?"]
        if typedKey.count == 1, let char = typedKey.first, sentenceEnders.contains(char) {
            shouldAutoCapitalize = true
            LogUtil.v(LogTagEnum.NORMAL_KEYBOARD_VIEW, "Typed sentence ender - preparing for auto capitalization")
        } else if typedKey == " " && shouldAutoCapitalize {
            // Keep auto capitalization enabled after space following sentence ender
            LogUtil.v(LogTagEnum.NORMAL_KEYBOARD_VIEW, "Typed space - maintaining auto capitalization state")
        } else if typedKey.rangeOfCharacter(from: .letters) != nil {
            // After typing a letter, disable auto capitalization unless it's the start of a new sentence
            if currentText.trimmingCharacters(in: .whitespacesAndNewlines).count <= 1 {
                // First character, keep auto cap for next sentence
                shouldAutoCapitalize = false
            } else {
                // Not the first character and not after sentence ender
                shouldAutoCapitalize = false
            }
        }
    }
    
}

//MARK: - Key Layout Calculation
extension NormalKeyboardView {
    struct KeyboardStats {
        let totalKeys: Int
        let textKeys: Int
        let specialKeys: Int
        let rows: Int
        let mode: KeyboardLayout.LayoutType
        
        var description: String {
            return "Mode: \(mode), Keys: \(totalKeys) (Text: \(textKeys), Special: \(specialKeys)), Rows: \(rows)"
        }
    }
    // MARK: - Key Item Calculation
    struct KeyItem {
        let key: String
        let displayText: String
        let frame: CGRect
        let keyType: KeyType
        let row: Int
        let column: Int
        let isSpecial: Bool
        
        enum KeyType {
            case text
            case action
            case icon
            case space
        }
    }
    
    private func getKeyboardStatistics(for keyItems: [KeyItem]) -> (totalKeys: Int, totalRows: Int) {
        let totalKeys = keyItems.count
        let totalRows = Set(keyItems.map { $0.row }).count
        return (totalKeys: totalKeys, totalRows: totalRows)
    }
    
    // Calculate all key items for the current layout
    private func calculateKeyItems(containerWidth: CGFloat) -> [KeyItem] {
        var keyItems: [KeyItem] = []
        let layout = currentLayout
        var currentY: CGFloat = 8 // top padding
        
        for (rowIndex, row) in layout.enumerated() {
            let rowKeyItems = calculateRowKeyItems(
                row: row,
                rowIndex: rowIndex,
                containerWidth: containerWidth,
                yPosition: currentY
            )
            keyItems.append(contentsOf: rowKeyItems)
            currentY += standardKeyHeight + rowSpacing
        }
        
        return keyItems
    }
    
    private func calculateRowKeyItems(
        row: [String],
        rowIndex: Int,
        containerWidth: CGFloat,
        yPosition: CGFloat
    ) -> [KeyItem] {
        var keyItems: [KeyItem] = []
        let availableWidth = containerWidth - (keyboardPadding * 2) // Now uses full width since padding = 0
        let totalSpacing = CGFloat(row.count - 1) * keySpacing
        let totalKeyWidth = availableWidth - totalSpacing
        
        // Calculate key widths based on key types
        let keyWidths = calculateKeyWidths(for: row, totalWidth: totalKeyWidth)
        
        // Calculate total width of this row (keys + spacing)
        let rowTotalWidth = keyWidths.reduce(0, +) + totalSpacing
        
        // Center the row by calculating the starting X position
        let startX = (containerWidth - rowTotalWidth) / 2.0
        var currentX: CGFloat = startX
        
        for (columnIndex, key) in row.enumerated() {
            let keyWidth = keyWidths[columnIndex]
            let keyFrame = CGRect(
                x: currentX,
                y: yPosition,
                width: keyWidth,
                height: standardKeyHeight
            )
            
            let keyItem = KeyItem(
                key: key,
                displayText: key,
                frame: keyFrame,
                keyType: getKeyType(for: key),
                row: rowIndex,
                column: columnIndex,
                isSpecial: KeyboardLayout.isSpecialKey(key)
            )
            
            keyItems.append(keyItem)
            currentX += keyWidth + keySpacing
        }
        
        return keyItems
    }
    
    private func calculateKeyWidths(for row: [String], totalWidth: CGFloat) -> [CGFloat] {
        var widths: [CGFloat] = []
        let availableWidth = totalWidth - (CGFloat(row.count - 1) * keySpacing)
        
        // Use the first row as reference for letter key size
        // First row: ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"] - all letters
        let referenceRow = currentLayout[0]
        let referenceLetterCount = referenceRow.count // Should be 10 letters
        let baseLetterKeyWidth = availableWidth / CGFloat(referenceLetterCount)
        
        // Calculate individual key widths
        for key in row {
            if key.count == 1 && key.rangeOfCharacter(from: CharacterSet.letters) != nil {
                // All letter keys use the same size as first row letters
                widths.append(baseLetterKeyWidth)
            } else {
                // Special keys get width based on their weight relative to letter keys
                let weight = getKeyWeight(for: key)
                let width = baseLetterKeyWidth * weight
                widths.append(width)
            }
        }
        
        return widths
    }
    
    private func getKeyWeight(for key: String) -> CGFloat {
        // Ensure all letter keys (a-z, A-Z) have the same weight
        if key.count == 1 && key.rangeOfCharacter(from: CharacterSet.letters) != nil {
            return 1.0 // All letter keys have exactly the same weight
        }
        
        guard let specialKey = KeyboardLayout.getSpecialKey(for: key) else {
            return 1.0 // Regular keys have weight 1
        }
        
        switch specialKey {
        case .space:
            return 5.0 // Space key is wider
        case .shift, .delete:
            return 1.5 // Action keys are slightly wider
        case .enter:
            return 1.5
        case .numbers, .symbols, .letters:
            return 1.5 // Mode change keys
        default:
            return 1.0
        }
    }
    
    // Calculate keyboard total height
    private func calculateKeyboardHeight() -> CGFloat {
        let numberOfRows = CGFloat(currentLayout.count)
        let totalRowSpacing = (numberOfRows - 1) * rowSpacing
        let totalKeyHeight = numberOfRows * standardKeyHeight
        let topBottomPadding: CGFloat = 18 // 8 + 10
        
        return totalKeyHeight + totalRowSpacing + topBottomPadding
    }
    
    // Calculate optimal key size for different screen sizes
    private func calculateOptimalKeySize(for screenSize: CGSize) -> CGFloat {
        let baseHeight: CGFloat = 44
        let screenWidth = screenSize.width
        
        // Adjust key height based on screen width
        switch screenWidth {
        case 0..<375: // iPhone SE, small screens
            return baseHeight * 0.9
        case 375..<414: // iPhone standard
            return baseHeight
        case 414..<500: // iPhone Plus, Max
            return baseHeight * 1.1
        default: // iPad and larger
            return baseHeight * 1.2
        }
    }
    
    private func recalculateKeyItems(for width: CGFloat) {
        containerWidth = width
        let keyItems = calculateKeyItems(containerWidth: width)
        
        DispatchQueue.main.async {
            calculatedKeyItems = keyItems
        }
        
        // Log keyboard statistics and width usage
        let stats = getKeyboardStatistics(for: keyItems)
        //        LogUtil.d(
        //            .NORMAL_KEYBOARD_VIEW,
        //            "Keyboard recalculated for FULL width: \(width), Total keys: \(stats.totalKeys), Rows: \(stats.totalRows)"
        //        )
        
        // Verify centering by checking leftmost and rightmost key positions
        if let leftmostKey = keyItems.min(by: { $0.frame.minX < $1.frame.minX }),
           let rightmostKey = keyItems.max(by: { $0.frame.maxX < $1.frame.maxX }) {
            let leftMargin = leftmostKey.frame.minX
            let rightMargin = width - rightmostKey.frame.maxX
        }
    }
}

#Preview("Custom Keyboard - Letters") {
    @Previewable @State var inputText: String = ""
    @Previewable @State var keyboardStats: String = "No stats yet"
    @Previewable @State var vm: KeyboardInputViewModel = KeyboardInputViewModel(inputText: "")
    
    
    
    VStack(alignment:.center) {
        WText("::: STATE INPUT :::").bold()
        WText("\(inputText)")
            .lineLimit(2)
            .truncationMode(.head)
        WText("::: VM INPUT :::").bold()
        WText("\(vm.inputText)")
            .lineLimit(2)
            .truncationMode(.head)
        
        GeometryReader { geometry in
            
            NormalKeyboardView(
                currentText: $vm.inputText,
                isAutoCapitalizationEnabled: true,
                isDoubleTapSpaceEnabled: true
            ) { key in
                inputText += key
                //vm.addInputText(key)
                vm.handleKeyboardInput(key){
                    print("Handled key: \($0.value)")
                }
            }
            .onAppear {
                // Calculate and display keyboard statistics
                let containerWidth = geometry.size.width
                keyboardStats = "Container: \(Int(containerWidth))x\(Int(geometry.size.height)) | Keys calculated for layout"
            }
        }
        .frame(height: 250)
        .environmentObject(vm)
        .keyboardBorderPreview()
    }
}

#Preview("Custom Keyboard - With Callback") {
    VStack(spacing: 20) {
        Text("Keyboard with Callback")
            .font(.headline)
        
        NormalKeyboardView(
            currentText: .constant("Hello"),
            isAutoCapitalizationEnabled: true,
            isDoubleTapSpaceEnabled: false
        ) { key in
            print("📝 Text key pressed: \(key)")
        }
        
        Text("Auto-Capitalization Disabled")
            .font(.headline)
        
        NormalKeyboardView(
            currentText: .constant(""),
            isAutoCapitalizationEnabled: false,
            isDoubleTapSpaceEnabled: false
        ) { key in
            print("📝 Text key pressed (no auto-cap, no double-tap): \(key)")
        }
        
        Text("Double Tap Space Disabled")
            .font(.headline)
        
        NormalKeyboardView(
            currentText: .constant("Test"),
            isAutoCapitalizationEnabled: true,
            isDoubleTapSpaceEnabled: false
        ) { key in
            print("📝 Text key pressed (no double-tap): \(key)")
        }
    }
    .padding()
}

#Preview("Custom Keyboard - All Modes") {
    VStack(spacing: 20) {
        Text("Letters Mode")
            .font(.headline)
        NormalKeyboardView(currentText: .constant("Hello")) { key in
            print("Key pressed: \(key)")
        }
        
        Text("Numbers Mode")
            .font(.headline)
        NormalKeyboardView(currentText: .constant("Hello")) { key in
            print("Key pressed: \(key)")
        }
        .onAppear {
            // This won't work in preview, but shows the concept
        }
        
        Text("Symbols Mode")
            .font(.headline)
        NormalKeyboardView(currentText: .constant("Hello")) { key in
            print("Key pressed: \(key)")
        }
    }
    .padding()
}


