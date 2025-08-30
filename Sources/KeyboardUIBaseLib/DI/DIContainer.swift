//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 26/8/25.
//

import Foundation

@MainActor
final class DIContainer: Sendable{
    static let shared = DIContainer()
    lazy var  sonaAPIService: SonaApiServiceProtocol = SonaApiService()
    lazy var loadingVM : LoadingViewModel = LoadingViewModel()
    lazy var toastMessageVM: ToastMessageManager = ToastMessageManager()
    lazy var sharedDataVM: SharedDataViewModel = SharedDataViewModel()
    lazy var keyboardVM: KeyboardInputViewModel = KeyboardInputViewModel(inputText: "")
}
