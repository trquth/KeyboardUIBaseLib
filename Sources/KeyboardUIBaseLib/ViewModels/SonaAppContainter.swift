//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 26/8/25.
//
import SwiftUI

@MainActor
class SonaAppContainer: ObservableObject {
    var sonaVM : SonaViewModel
    var loadingVM: LoadingViewModel
    var toastMessageVM: ToastMessageManager
    var sharedDataVM: SharedDataViewModel
    var keyboardVM: KeyboardInputVM
    
    init(container: DIContainer) {
        let loadingVM = container.loadingVM
        self.keyboardVM = container.keyboardVM
        self.sonaVM = SonaViewModel(sonaApiService: container.sonaAPIService,
                                    loadingVM: loadingVM)
        self.loadingVM = loadingVM
        self.toastMessageVM = container.toastMessageVM
        self.sharedDataVM = container.sharedDataVM
    }
}

