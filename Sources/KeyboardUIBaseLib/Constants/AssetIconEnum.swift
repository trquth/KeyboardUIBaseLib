//
//  IconContant.swift
//  BaseKeyboard
//
//  Created by Thien Tran-Quan on 15/8/25.
//

import Foundation

// MARK: - Asset Icon Enums for Keyboard App
enum AssetIconEnum: String, CaseIterable {
    // MARK: - Existing Assets
    case delete = "delete_ico"
    case emoji = "emoji_ico"
    case enter = "enter_ico"
    case upperCase = "upper_case_ico"
    
    // MARK: - Computed Properties
    var fileName: String {
        return self.rawValue
    }
}
