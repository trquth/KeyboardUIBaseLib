//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 26/8/25.
//
import SwiftUI
import Combine

@MainActor
class SonaAppContainer: ObservableObject {
    @Published var sonaVM : SonaVM
    @Published var loadingVM: LoadingVM
    
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        let loadingVM = container.loadingVM
        self.sonaVM = SonaVM(sonaApiService: container.sonaAPIService,
                             loadingVM: loadingVM)
        self.loadingVM = loadingVM
        
        // Forward LoadingVM's published changes to this container
        loadingVM.objectWillChange
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.objectWillChange.send()
                }
            }
            .store(in: &cancellables)
    }
}

