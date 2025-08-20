//
//  WImage.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 20/8/25.
//

import SwiftUI

struct WImage: View {
    private let imageName: String
    private let bundle: Bundle?
    private let renderingMode: Image.TemplateRenderingMode?
    private let foregroundColor: Color?
    
    init(_ imageName: String, bundle: Bundle? = nil, renderingMode: Image.TemplateRenderingMode? = nil, foregroundColor: Color? = nil) {
        self.imageName = imageName
        self.bundle = bundle ?? WImage.resourceBundle
        self.renderingMode = renderingMode
        self.foregroundColor = foregroundColor
    }
    
    var body: some View {
        let baseImage: Image
        
        if let bundle = bundle {
            baseImage = Image(imageName, bundle: bundle)
        } else {
            baseImage = Image(imageName)
        }
        
        let resizableImage = baseImage.resizable()
        
        return Group {
            if let renderingMode = renderingMode {
                if let foregroundColor = foregroundColor {
                    resizableImage
                        .renderingMode(renderingMode)
                        .foregroundColor(foregroundColor)
                } else {
                    resizableImage
                        .renderingMode(renderingMode)
                }
            } else {
                if let foregroundColor = foregroundColor {
                    resizableImage
                        .foregroundColor(foregroundColor)
                } else {
                    resizableImage
                }
            }
        }
    }
    
    // Helper to get the correct resource bundle
    private static var resourceBundle: Bundle? {
        #if COCOAPODS
        print("Using CocoaPods bundle for resources")
        // For CocoaPods, resources are in a named bundle
        let bundleName = "KeyboardUIBaseLib"
        guard let bundleURL = Bundle(for: BundleToken.self).url(forResource: bundleName, withExtension: "bundle"),
              let bundle = Bundle(url: bundleURL) else {
            return Bundle.main
        }
        return bundle
        #elseif SWIFT_PACKAGE
        print("Using module bundle for resources")
        // For Swift Package Manager, we need to find the module bundle
        return Bundle.module
        #else
        print("Using main bundle for resources")
        return Bundle.main
        #endif
    }
}

// Helper class to get the current bundle
private class BundleToken {}

// MARK: - WImage Extensions
extension WImage {
    func renderingMode(_ renderingMode: Image.TemplateRenderingMode) -> WImage {
        WImage(imageName, bundle: bundle, renderingMode: renderingMode, foregroundColor: foregroundColor)
    }
    
    func foregroundColor(_ color: Color) -> WImage {
        WImage(imageName, bundle: bundle, renderingMode: renderingMode, foregroundColor: color)
    }
}

#Preview {
    VStack(spacing: 20) {
        WImage("close_ico")
            .frame(width: 24, height: 24)
        
        WImage("delete_ico")
            .frame(width: 24, height: 24)
        
        WImage("emoji_ico")
            .frame(width: 24, height: 24)
        
        WImage("close_ico")
            .frame(width: 30, height: 30)
            .foregroundColor(.blue)
    }
    .padding()
}
