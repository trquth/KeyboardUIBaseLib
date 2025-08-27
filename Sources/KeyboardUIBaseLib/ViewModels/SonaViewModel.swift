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
    
    init(sonaApiService: SonaApiServiceProtocol, loadingVM: LoadingViewModel) {
        self.sonaApiService = sonaApiService
        self.loadingVM = loadingVM
    }
    
    func rewriteText(_ data: RewriteRequestParam) async throws -> Void {
        do {
            loadingVM.startLoading()
            try await sonaApiService.rewriteApi(data)
            loadingVM.stopLoading()
        } catch  {
            loadingVM.stopLoading()
        }
    }
}
