//
//  SonaViewModel.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 23/8/25.
//

import SwiftUI

@MainActor
final class SonaViewModel: ObservableObject {
    private let sonaApiService: SonaApiServiceProtocol
    private let loadingVM: LoadingViewModel
    
    @Published var input:String = ""
    @Published var tone: String = ""
    @Published var persona: String = ""
    
    
    init(sonaApiService: SonaApiServiceProtocol, loadingVM: LoadingViewModel) {
        self.sonaApiService = sonaApiService
        self.loadingVM = loadingVM
    }
    
    func rewriteText(_ data: RewriteRequestParam) async throws -> Void {
        do {
            // Validate input data using RewriteValidator
            try RewriteValidator.validate(data)
            
            loadingVM.startLoading()
            try await sonaApiService.rewriteApi(data)
            loadingVM.stopLoading()
        } catch {
            loadingVM.stopLoading()
            throw error // Re-throw validation or API errors
        }
    }
    
    func selectTone(_ tone: String) {
        self.tone = tone
    }
    
    func selectPersona(_ persona: String) {
        self.persona = persona
    }
}
