//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 22/8/25.
//

import Foundation
import Alamofire

enum HTTPMethodEnum: String, CaseIterable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
    
    var httpMethod: HTTPMethod {
        return HTTPMethod(rawValue: self.rawValue)
    }
}
