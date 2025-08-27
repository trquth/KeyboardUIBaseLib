//
//  LoadingViewModel.swift
//  KeyboardUIBaseLib
//
//  Created by Assistant on 26/8/25.
//

import SwiftUI

@MainActor
class LoadingViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    
    // MARK: - Public Methods
    
    /// Start loading
    func startLoading() {
        print("Start loading...")
        isLoading = true
    }
    
    /// Stop loading
    func stopLoading() {
        print("Stop loading...")
        isLoading = false
    }
    
    /// Toggle loading state
    func toggleLoading() {
        isLoading.toggle()
    }
    
    /// Set loading state
    func setLoading(_ loading: Bool) {
        isLoading = loading
    }
}
