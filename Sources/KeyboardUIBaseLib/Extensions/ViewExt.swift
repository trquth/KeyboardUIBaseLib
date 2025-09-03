//
//  ViewExt.swift
//  Pods
//
//  Created by Thien Tran-Quan on 3/9/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func onChangeCompact<T: Equatable>(
        of value: T,
        perform action: @escaping (T) -> Void
    ) -> some View {
        if #available(iOS 17, *) {
            // iOS 17+ dùng new API (oldValue, newValue)
            self.onChange(of: value) { _, newValue in
                action(newValue)
            }
        } else {
            // iOS 14–16 dùng old API
            self.onChange(of: value, perform: action)
        }
    }
}
