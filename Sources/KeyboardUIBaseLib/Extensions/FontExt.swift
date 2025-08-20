//
//  FontExt.swift
//  BaseKeyboard
//
//  Created by Thien Tran-Quan on 16/8/25.
//

import SwiftUI
import UIKit

// MARK: - Custom Font Names (Based on your project fonts)
enum FontName: String, CaseIterable {
    case interRegular = "Inter18pt-Regular"
    case interMedium = "Inter18pt-Medium"
    case interBold = "Inter18pt-Bold"
    case interSemiBold = "Inter18pt-SemiBold"
    case zenLoopRegular = "ZenLoop-Regular"
    
    var displayName: String {
        switch self {
        case .interRegular:
            return "Inter_18pt-Regular"
        case .interMedium:
            return "Inter_18pt-Medium"
        case .interBold:
            return "Inter_18pt-Bold"
        case .interSemiBold:
            return "Inter_18pt-SemiBold"
        case .zenLoopRegular:
            return "ZenLoop-Regular"
        }
    }
}

// MARK: - Font Extension for Font Name Access
extension Font {
    // MARK: - Font Creation Methods
    static func custom(_ fontName: FontName, size: CGFloat) -> Font {
        return Font.custom(fontName.rawValue, size: size)
    }
    
    static func custom(_ fontName: FontName, fixedSize: CGFloat) -> Font {
        return Font.custom(fontName.rawValue, fixedSize: fixedSize)
    }
    
    // MARK: - Font Logging Functions
    /// Log all available fonts in the app to console
    static func logAllAvailableFonts() {
        print("=== All Available Fonts in App ===")
        let sortedFamilies = UIFont.familyNames.sorted()
        
        for family in sortedFamilies {
            print("📁 Font Family: \(family)")
            let fontNames = UIFont.fontNames(forFamilyName: family).sorted()
            for fontName in fontNames {
                print("   📝 \(fontName)")
            }
            print() // Empty line for readability
        }
        
        print("📊 Total font families: \(sortedFamilies.count)")
        let totalFonts = sortedFamilies.reduce(0) { count, family in
            return count + UIFont.fontNames(forFamilyName: family).count
        }
        print("📊 Total fonts: \(totalFonts)")
        print("=====================================\n")
    }
    
    public static func registerCustomFonts() {
        for font in FontName.allCases {
            guard let url = Bundle.main.url(forResource: font.displayName, withExtension: "ttf") else { return }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}

extension View {
//    https://dev.jeremygale.com/swiftui-how-to-use-custom-fonts-and-images-in-a-swift-package-cl0k9bv52013h6bnvhw76alid
    /// Attach this to any Xcode Preview's view to have custom fonts displayed
    /// Note: Not needed for the actual app
    public func loadCustomFonts() -> some View {
        Font.registerCustomFonts()
        
        Font.logAllAvailableFonts()
        return self
    }
}
