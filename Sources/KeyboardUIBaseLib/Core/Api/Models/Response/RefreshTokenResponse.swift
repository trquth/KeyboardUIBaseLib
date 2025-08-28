//
//  RefreshTokenResponse.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 28/8/25.
//

import Foundation

/// Response model for token refresh API calls
public struct RefreshTokenResponse: Codable, Sendable {
    let message: String
    let data: TokenData
}

struct TokenData: Codable {
    let accessToken: String
}
