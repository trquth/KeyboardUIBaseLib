
//
//  CustomKeyboardView.swift
//  BaseKeyboard
//
//  Created by Thien Tran-Quan on 11/8/25.
//

import SwiftUI

struct NormalKeyboardView: View {
    @State private var isShiftActive = false
    @State private var isCapsLockActive = false
    @State private var currentKeyboardMode: KeyboardLayout.LayoutType = .letters
    @State private var lastShiftTapTime: Date = Date()
    @State private var calculatedKeyItems: [KeyItem] = []
    @State private var containerWidth: CGFloat = 0
    
    // Callback for key presses
    let onKeyPressed: ((String) -> Void)?
    
    // Keyboard layout constants
    private let standardKeyHeight: CGFloat = 44
    private let rowSpacing: CGFloat = 12.4
    private let keySpacing: CGFloat = 4.0 // Reduced spacing for better full-width usage
    private let keyboardPadding: CGFloat = 0 // Use full width - no padding
    
    init(onKeyPressed: ((String) -> Void)? = nil) {
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
        if isCapsLockActive || isShiftActive {
            return key.uppercased()
        }
        return key.lowercased()
    }
    
    // MARK: - Key Handling Methods
    
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
    
    private func handleCharacterKey(_ key: String) -> String {
        let actualKey: String
        if currentKeyboardMode == .letters {
            actualKey = (isCapsLockActive || isShiftActive) ? key.uppercased() : key.lowercased()
            // Auto-disable shift after typing a letter (single shift behavior, but not caps lock)
            if isShiftActive && !isCapsLockActive {
                isShiftActive = false
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
        isShiftActive = false
        isCapsLockActive = false
        LogUtil.d(.NORMAL_KEYBOARD_VIEW, "Switched to numbers mode")
    }
    
    private func switchToLettersMode() {
        currentKeyboardMode = .letters
        LogUtil.d(.NORMAL_KEYBOARD_VIEW, "Switched to letters mode")
    }
    
    private func switchToSymbolsMode() {
        currentKeyboardMode = .symbols
        isShiftActive = false
        isCapsLockActive = false
        LogUtil.d(.NORMAL_KEYBOARD_VIEW, "Switched to symbols mode")
    }
    
    private func handleKeyPress(_ key: String) {
        // Always call the callback with the actual character
        
        let actualKey =  handleCharacterKey(key)
        
        // Handle special key actions
        guard let specialKey = KeyboardLayout.getSpecialKey(for: key) else {
            // Regular text key
            LogUtil.i(.NORMAL_KEYBOARD_VIEW, "REGULAR text key pressed: \(actualKey)")
            return
        }
        LogUtil.i(.NORMAL_KEYBOARD_VIEW, "SPECIAL key pressed: \(specialKey)")
        
        switch specialKey {
        case .numbers:
            switchToNumbersMode()
        case .symbols:
            switchToSymbolsMode()
        case .letters:
            currentKeyboardMode = .letters
        case .shift:
            handleShift()
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
    
    //
    private func renderSpaceButton(_ keyItem: KeyItem) -> some View {
        TextKeyboardButton(
            text: KeyboardLayout.SpecialKey.space.keyDisplay,
            width: keyItem.frame.width,
            height: keyItem.frame.height,
            titleFontSize: 18
            
        ) {
            handleKeyPress(keyItem.key)
        }
    }
    
    private func renderIconKeyButton(_ keyItem: KeyItem,withAsset asset: AssetIconEnum) -> some View {
        IconKeyboardButton(
            assetName: asset.rawValue,
            width: keyItem.frame.width,
            height: keyItem.frame.height,
            foregroundColor:.black
        ) {
            handleKeyPress(keyItem.key)
        }
    }
    
    private func renderTextKeyButton(_ keyItem: KeyItem, withTitle title: String = "") -> some View {
        TextKeyboardButton(
            text: title.isEmpty ? getDisplayText(for: keyItem.key) : title,
            width: keyItem.frame.width,
            height: keyItem.frame.height
        ) {
            handleKeyPress(keyItem.key)
        }
    }
    
    private func renderActionKeyButton(_ keyItem: KeyItem, withTitle title: String = "") -> some View {
        return TextKeyboardButton(
            text: title.isEmpty ? keyItem.displayText : title,
            width: keyItem.frame.width,
            height: keyItem.frame.height,
            titleFontSize: 16,
            buttonStyle: .minimal
        ) {
            handleKeyPress(keyItem.key)
        }
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
                    renderIconKeyButton(keyItem, withAsset: .upperCase)
                case .delete:
                    renderIconKeyButton(keyItem, withAsset: .delete)
                case .enter:
                    renderIconKeyButton(keyItem, withAsset: .enter)
                case .numbers:
                    renderActionKeyButton(keyItem, withTitle: "?123")
                case .letters:
                    renderActionKeyButton(keyItem, withTitle: "ABC")
                case .symbols:
                    renderActionKeyButton(keyItem, withTitle: "#+")
                case .dot:
                    switch currentKeyboardMode {
                    case .numbers, .symbols:
                        renderTextKeyButton(keyItem, withTitle: ".")
                    default:
                        renderActionKeyButton(keyItem, withTitle: ".")
                    }
                case .emoji:
                    renderIconKeyButton(keyItem, withAsset: .emoji)
                case .globe:
                    renderIconKeyButton(keyItem, withAsset: .emoji)
                }
            } else {
                renderTextKeyButton(keyItem)
            }
        } else {
            renderTextKeyButton(keyItem)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Calculate key items when geometry changes
                Color.clear
                    .onAppear {
                        recalculateKeyItems(for: geometry.size.width)
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
                        )
                }.onChangeCompact(of: currentKeyboardMode, perform: { _ in
                    recalculateKeyItems(for: geometry.size.width)
                })
            }
        }
        .frame(height: calculateKeyboardHeight())
    }
}

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
                displayText: getDisplayText(for: key),
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
        LogUtil.d(
            .NORMAL_KEYBOARD_VIEW,
            "Keyboard recalculated for FULL width: \(width), Total keys: \(stats.totalKeys), Rows: \(stats.totalRows)"
        )
        
        // Verify centering by checking leftmost and rightmost key positions
        if let leftmostKey = keyItems.min(by: { $0.frame.minX < $1.frame.minX }),
           let rightmostKey = keyItems.max(by: { $0.frame.maxX < $1.frame.maxX }) {
            let leftMargin = leftmostKey.frame.minX
            let rightMargin = width - rightmostKey.frame.maxX
            LogUtil.d(
                .NORMAL_KEYBOARD_VIEW,
                "Centering: Left margin: \(leftMargin), Right margin: \(rightMargin), Difference: \(abs(leftMargin - rightMargin))"
            )
        }
    }
    
}

extension View {
    @ViewBuilder
    func onChangeCompact<T: Equatable>(
        of value: T,
        perform action: @escaping (T) -> Void
    ) -> some View {
        if #available(iOS 17, *) {
            // iOS 17+ dùng new API (oldValue, newValue)
            self.onChange(of: value) { _, newValue in
                action(newValue)
            }
        } else {
            // iOS 14–16 dùng old API
            self.onChange(of: value, perform: action)
        }
    }
}

#Preview("Custom Keyboard - Letters") {
    @Previewable @State var inputText: String = ""
    @Previewable @State var keyboardStats: String = "No stats yet"
    
    VStack(alignment:.center) {
        WText("::: INPUT :::").bold()
        WText("\(inputText)")
        WText("::: STATS :::").bold()
        WText("\(keyboardStats)")
            .font(.caption)
            .foregroundColor(.secondary)
        
        GeometryReader { geometry in
            NormalKeyboardView { key in
                inputText += key
            }
            .onAppear {
                // Calculate and display keyboard statistics
                let containerWidth = geometry.size.width
                keyboardStats = "Container: \(Int(containerWidth))x\(Int(geometry.size.height)) | Keys calculated for layout"
            }
        }
        .frame(height: 250)
        .border(.yellow, width: 1)
    }
}

#Preview("Custom Keyboard - With Callback") {
    VStack(spacing: 20) {
        Text("Keyboard with Callback")
            .font(.headline)
        
        NormalKeyboardView { key in
            print("📝 Text key pressed: \(key)")
        }
    }
    .padding()
}

#Preview("Custom Keyboard - All Modes") {
    VStack(spacing: 20) {
        Text("Letters Mode")
            .font(.headline)
        NormalKeyboardView { key in
            print("Key pressed: \(key)")
        }
        
        Text("Numbers Mode")
            .font(.headline)
        NormalKeyboardView { key in
            print("Key pressed: \(key)")
        }
        .onAppear {
            // This won't work in preview, but shows the concept
        }
        
        Text("Symbols Mode")
            .font(.headline)
        NormalKeyboardView { key in
            print("Key pressed: \(key)")
        }
    }
    .padding()
}

