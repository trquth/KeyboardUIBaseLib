//
//  SwiftUIView.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 2/9/25.
//

import SwiftUI

extension View {
    func debugLog(_ message: String) -> some View {
        print(message)   // in log ngay khi body được build lại
        return self
    }
}
