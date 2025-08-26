//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 26/8/25.
//
import SwiftUI

@MainActor
class SonaAppContainer: ObservableObject {
    let loadingVM = LoadingVM()
    lazy var sonaVM = SonaVM(sonaApiService: DIContainer.shared.sonaAPIService, loadingVM: loadingVM)
}

