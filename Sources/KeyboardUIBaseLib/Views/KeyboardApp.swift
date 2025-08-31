//
//  SwiftUIView.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 22/8/25.
//

import SwiftUI

public struct KeyboardApp: View {
    @StateObject private var container = SonaAppContainer(container: DIContainer.shared)
    
    public init() {}
    
    public  var body: some View {
        MainView()
            .loadCustomFonts()
            .setupCommonEnvironmentObjects(container)
    }
}

#Preview("Input text") {
    @Previewable @StateObject var container = SonaAppContainer(container: DIContainer.shared)
    @Previewable @StateObject var vm = KeyboardInputViewModel(inputText: "")
    
    VStack {
        WText("::: Input text :::")
            .bold()
        WText("\(vm.inputText)")
        WText("::: Last word :::")
            .bold()
        WText("\(vm.lastWordTyped)")
        MainView()
            .keyboardFramePreview()
            .environmentObject(vm)
            .environmentObject(container.sharedDataVM)
            //.setupCommonEnvironmentObjects(container)
    }
}

#Preview {
    @Previewable @StateObject var container = SonaAppContainer(container: DIContainer.shared)
    KeyboardApp()
        .keyboardFramePreview()
        .environmentObject(container.sharedDataVM)
}



