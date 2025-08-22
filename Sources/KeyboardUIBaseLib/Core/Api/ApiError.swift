//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 22/8/25.
//

import Foundation

enum ApiError: Error, LocalizedError {
    case http(statusCode: Int, data: Data?)
    case decoding(Error)
    case underlying(Error)
    case invalidURL
    case noData
    case timeout
    case networkUnavailable
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .http(let statusCode, _):
            return "HTTP Error: \(statusCode)"
        case .decoding(let error):
            return "Decoding Error: \(error.localizedDescription)"
        case .underlying(let error):
            return "Network Error: \(error.localizedDescription)"
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .timeout:
            return "Request timeout"
        case .networkUnavailable:
            return "Network unavailable"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}
