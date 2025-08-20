//
//  BundleExt.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 20/8/25.
//

import Foundation

// MARK: - Bundle Extension for Resource Management
extension Bundle {
    
    /// Get pod resource bundle by name
    static func podResource(named bundleName: String, for aClass: AnyClass) -> Bundle? {
        let podBundle = Bundle(for: aClass)
        guard let url = podBundle.url(forResource: bundleName, withExtension: "bundle") else {
            return nil
        }
        return Bundle(url: url)
    }
    
    /// Get the correct resource bundle for KeyboardUIBaseLib
    static func getKeyboardUIBaseLibResourceBundle() -> Bundle {
        #if COCOAPODS
        // For CocoaPods, resources are in a named bundle
        let bundleName = "KeyboardUIBaseLibAssets"
        print("🔍 Looking for CocoaPods bundle: \(bundleName)")
        
        let tokenBundle = Bundle(for: BundleToken.self)
        print("📦 Token bundle path: \(tokenBundle.bundlePath)")
        print("📦 Token bundle identifier: \(tokenBundle.bundleIdentifier ?? "Unknown")")
        
        guard let bundleURL = tokenBundle.url(forResource: bundleName, withExtension: "bundle") else {
            print("⚠️ Could not find bundle URL for: \(bundleName).bundle")
            print("📝 Available resources in token bundle:")
            if let resourcePath = tokenBundle.resourcePath {
                do {
                    let contents = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                    for item in contents.sorted() {
                        print("   - \(item)")
                    }
                } catch {
                    print("   ❌ Error reading token bundle: \(error)")
                }
            }
            print("🔄 Falling back to main bundle")
            return Bundle.main
        }
        
        guard let bundle = Bundle(url: bundleURL) else {
            print("⚠️ Could not create bundle from URL: \(bundleURL)")
            print("🔄 Falling back to main bundle")
            return Bundle.main
        }
        
        print("✅ Successfully found CocoaPods resource bundle")
        return bundle
        #elseif SWIFT_PACKAGE
        print("🔍 Using Swift Package Manager bundle")
        return Bundle.module
        #else
        print("🔍 Using main bundle (default)")
        return Bundle.main
        #endif
    }
    
    /// Log all files and directories in the bundle
    func logBundleContents() {
        print("=== Bundle Contents ===")
        
        guard let resourcePath = self.resourcePath else {
            print("⚠️ No resource path found in bundle")
            return
        }
        
        do {
            let fileManager = FileManager.default
            let contents = try fileManager.contentsOfDirectory(atPath: resourcePath)
            
            print("📁 Resource path: \(resourcePath)")
            print("📝 Files and directories in bundle:")
            
            for item in contents.sorted() {
                let itemPath = (resourcePath as NSString).appendingPathComponent(item)
                var isDirectory: ObjCBool = false
                
                if fileManager.fileExists(atPath: itemPath, isDirectory: &isDirectory) {
                    if isDirectory.boolValue {
                        print("   📁 \(item)/")
                        // Recursively list subdirectories
                        logDirectoryContents(path: itemPath, prefix: "      ")
                    } else {
                        print("   📄 \(item)")
                    }
                }
            }
            
            print("📊 Total items: \(contents.count)")
        } catch {
            print("❌ Error reading bundle contents: \(error)")
        }
        
        print("=======================\n")
    }
    
    /// Recursively log directory contents
    private func logDirectoryContents(path: String, prefix: String) {
        do {
            let fileManager = FileManager.default
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            
            for item in contents.sorted() {
                let itemPath = (path as NSString).appendingPathComponent(item)
                var isDirectory: ObjCBool = false
                
                if fileManager.fileExists(atPath: itemPath, isDirectory: &isDirectory) {
                    if isDirectory.boolValue {
                        print("\(prefix)📁 \(item)/")
                        logDirectoryContents(path: itemPath, prefix: prefix + "   ")
                    } else {
                        print("\(prefix)📄 \(item)")
                    }
                }
            }
        } catch {
            print("\(prefix)❌ Error reading directory \(path): \(error)")
        }
    }
    
    /// Log basic bundle information
    func logBundleInfo() {
        print("=== Bundle Information ===")
        print("📦 Bundle path: \(self.bundlePath)")
        print("🏷️ Bundle identifier: \(self.bundleIdentifier ?? "Unknown")")
        print("📋 Bundle info: \(self.infoDictionary?["CFBundleName"] as? String ?? "Unknown")")
        print("==========================\n")
    }
}

// Helper class to get the current bundle for CocoaPods
class BundleToken {}
