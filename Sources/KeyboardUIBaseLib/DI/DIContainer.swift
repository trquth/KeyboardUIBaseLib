//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 26/8/25.
//

import Foundation

final class DIContainer: Sendable{
   static let shared = DIContainer()
    
    var sonaAPIService: SonaApiServiceProtocol  {
        SonaApiService()
    }
}
