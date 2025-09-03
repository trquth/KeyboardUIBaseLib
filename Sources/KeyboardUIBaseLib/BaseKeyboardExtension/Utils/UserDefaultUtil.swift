//
//  UserDefaultUtil.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 3/9/25.
//

import Foundation

public class UserDefaultUtil {
    
    // MARK: - Standard UserDefaults
    
    /// Save data to standard UserDefaults
    public static func saveData<T: Codable>(_ data: T, forKey key: String) {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(data)
            UserDefaults.standard.set(encodedData, forKey: key)
        } catch {
            print("Failed to save data to UserDefaults: \(error)")
        }
    }
    
    /// Get data from standard UserDefaults
    public static func getData<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(type, from: data)
            return decodedData
        } catch {
            print("Failed to decode data from UserDefaults: \(error)")
            return nil
        }
    }
    
    /// Save primitive value to standard UserDefaults
    public static func saveValue<T>(_ value: T, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    /// Get primitive value from standard UserDefaults
    public static func getValue<T>(_ type: T.Type, forKey key: String, defaultValue: T? = nil) -> T? {
        let value = UserDefaults.standard.object(forKey: key) as? T
        return value ?? defaultValue
    }
    
    /// Remove data from standard UserDefaults
    public static func removeData(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    // MARK: - App Group UserDefaults
    
    /// Save data to App Group UserDefaults
    public static func saveDataToAppGroup<T: Codable>(_ data: T, forKey key: String, groupIdentifier: String) {
        guard let appGroupDefaults = UserDefaults(suiteName: groupIdentifier) else {
            print("Failed to create UserDefaults for App Group: \(groupIdentifier)")
            return
        }
        
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(data)
            appGroupDefaults.set(encodedData, forKey: key)
        } catch {
            print("Failed to save data to App Group UserDefaults: \(error)")
        }
    }
    
    /// Get data from App Group UserDefaults
    public static func getDataFromAppGroup<T: Codable>(_ type: T.Type, forKey key: String, groupIdentifier: String) -> T? {
        guard let appGroupDefaults = UserDefaults(suiteName: groupIdentifier) else {
            print("Failed to create UserDefaults for App Group: \(groupIdentifier)")
            return nil
        }
        
        guard let data = appGroupDefaults.data(forKey: key) else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(type, from: data)
            return decodedData
        } catch {
            print("Failed to decode data from App Group UserDefaults: \(error)")
            return nil
        }
    }
    
    /// Save primitive value to App Group UserDefaults
    public static func saveValueToAppGroup<T>(_ value: T, forKey key: String, groupIdentifier: String) {
        guard let appGroupDefaults = UserDefaults(suiteName: groupIdentifier) else {
            print("Failed to create UserDefaults for App Group: \(groupIdentifier)")
            return
        }
        
        appGroupDefaults.set(value, forKey: key)
    }
    
    /// Get primitive value from App Group UserDefaults
    public static func getValueFromAppGroup<T>(_ type: T.Type, forKey key: String, groupIdentifier: String, defaultValue: T? = nil) -> T? {
        guard let appGroupDefaults = UserDefaults(suiteName: groupIdentifier) else {
            print("Failed to create UserDefaults for App Group: \(groupIdentifier)")
            return defaultValue
        }
        
        let value = appGroupDefaults.object(forKey: key) as? T
        return value ?? defaultValue
    }
    
    /// Remove data from App Group UserDefaults
    public static func removeDataFromAppGroup(forKey key: String, groupIdentifier: String) {
        guard let appGroupDefaults = UserDefaults(suiteName: groupIdentifier) else {
            print("Failed to create UserDefaults for App Group: \(groupIdentifier)")
            return
        }
        
        appGroupDefaults.removeObject(forKey: key)
    }
    
    // MARK: - Convenience Methods with App Group Instance
    
    /// Create a UserDefaults instance for App Group
    public static func appGroupDefaults(for groupIdentifier: String) -> UserDefaults? {
        return UserDefaults(suiteName: groupIdentifier)
    }
    
    /// Check if App Group is available
    public static func isAppGroupAvailable(_ groupIdentifier: String) -> Bool {
        return UserDefaults(suiteName: groupIdentifier) != nil
    }
    
    // MARK: - Migration Helpers
    
    /// Migrate data from standard UserDefaults to App Group UserDefaults
    public static func migrateToAppGroup(key: String, groupIdentifier: String, removeFromStandard: Bool = true) {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            print("No data found in standard UserDefaults for key: \(key)")
            return
        }
        
        guard let appGroupDefaults = UserDefaults(suiteName: groupIdentifier) else {
            print("Failed to create UserDefaults for App Group: \(groupIdentifier)")
            return
        }
        
        appGroupDefaults.set(data, forKey: key)
        
        if removeFromStandard {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        print("Successfully migrated data for key '\(key)' to App Group: \(groupIdentifier)")
    }
    
    /// Migrate data from App Group UserDefaults to standard UserDefaults
    public static func migrateFromAppGroup(key: String, groupIdentifier: String, removeFromAppGroup: Bool = true) {
        guard let appGroupDefaults = UserDefaults(suiteName: groupIdentifier) else {
            print("Failed to create UserDefaults for App Group: \(groupIdentifier)")
            return
        }
        
        guard let data = appGroupDefaults.data(forKey: key) else {
            print("No data found in App Group UserDefaults for key: \(key)")
            return
        }
        
        UserDefaults.standard.set(data, forKey: key)
        
        if removeFromAppGroup {
            appGroupDefaults.removeObject(forKey: key)
        }
        
        print("Successfully migrated data for key '\(key)' from App Group: \(groupIdentifier)")
    }
}
