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
    
    @Published var input:String = "Hello I im Binhdadads"
    @Published private(set) var selectedTone: String = "Neutral" // Default tone
    @Published private(set) var selectedPersona: String = "Neutral" //Default persona
    
    
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
        self.selectedTone = tone
    }
    
    func selectPersona(_ persona: String) {
        self.selectedPersona = persona
    }
}
