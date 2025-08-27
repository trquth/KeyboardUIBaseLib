//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 27/8/25.
//

import Foundation
import Alamofire

struct ApiBaseUtil {
    // MARK: - Private Helper Methods
    
    static func logCurlCommand(for request: DataRequest) {
        guard let urlRequest = request.request else {
            print("⚠️ ApiBase: Unable to generate cURL - URLRequest is nil")
            return
        }
        
        let curlCommand = generateCurlCommand(from: urlRequest)
        print("""
        
        📋 =================== cURL Command ===================
        \(curlCommand)
        ====================================================
        
        """)
    }
    
    private  static func generateCurlCommand(from urlRequest: URLRequest) -> String {
        var components = ["curl"]
        
        // Add HTTP method
        if let method = urlRequest.httpMethod {
            components.append("-X \(method)")
        }
        
        // Add URL
        if let url = urlRequest.url?.absoluteString {
            components.append("'\(url)'")
        }
        
        // Add headers
        if let headers = urlRequest.allHTTPHeaderFields {
            let sortedHeaders = headers.sorted { $0.key < $1.key }
            for (key, value) in sortedHeaders {
                components.append("-H '\(key): \(value)'")
            }
        }
        
        // Add body data
        if let httpBody = urlRequest.httpBody {
            if let bodyString = String(data: httpBody, encoding: .utf8) {
                // Format JSON body if possible
                let formattedBody = formatJsonBody(bodyString)
                components.append("-d '\(formattedBody)'")
            } else {
                components.append("-d '[Binary Data]'")
            }
        }
        
        // Join with proper line breaks for readability
        return components.joined(separator: " \\\n  ")
    }
    
    private static func formatJsonBody(_ body: String) -> String {
        guard let data = body.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data),
              let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: []),
              let compactString = String(data: prettyData, encoding: .utf8) else {
            return body
        }
        return compactString
    }
}
