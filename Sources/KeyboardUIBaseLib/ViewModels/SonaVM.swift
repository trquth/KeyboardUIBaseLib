//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 23/8/25.
//

import SwiftUI

final class SonaVM: ObservableObject {
    private var sonaApiService: SonaApiServiceProtocol = SonaApiService()
    
//    init(sonaApiService: SonaApiServiceProtocol) {
//          _sonaApiService = sonaApiService
//      }
    @MainActor
    func rewriteText(input: String, tone: String, persona: String)  async throws -> Void {
        Task { @MainActor in
            do {
                let data =  try await sonaApiService.rewrite()
                print("Rewrite Text Data: \(data)")
            } catch {
                print("Error in rewriteText: \(error)")
            }
        }
        
        
//        try? await sonaApiService.postExample()
    }
}
