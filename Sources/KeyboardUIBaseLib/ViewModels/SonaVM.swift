//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 23/8/25.
//

import SwiftUI

@MainActor
final class SonaVM: ObservableObject {
    private let sonaApiService: SonaApiServiceProtocol
    
    init(sonaApiService: SonaApiServiceProtocol) {
        self.sonaApiService = sonaApiService
    }
    
    func rewriteText(_ data: RewriteRequestParam) async throws -> Void {
        do {
            let data = try await sonaApiService.rewriteApi(data)
            print("Rewrite Text Data: \(data)")
        } catch {
            print("Error in rewriteText: \(error)")
        }
    }
}
