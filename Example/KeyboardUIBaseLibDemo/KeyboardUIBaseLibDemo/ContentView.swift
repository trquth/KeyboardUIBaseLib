//
//  ContentView.swift
//  KeyboardUIBaseLibDemo
//
//  Created by Thien Tran-Quan on 20/8/25.
//

import SwiftUI
import KeyboardUIBaseLib

struct ContentView: View {
    
    private let shared = UserDefaults(suiteName: "group.keyboarduibaselib")
    
    @State var token: String = ""

    
    private func onSaveToken(){
        shared?.set("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2OGFjMmU4YmQwZWUxMzIwMDMzZTVjMTgiLCJpYXQiOjE3NTYzNDY2NjQsImV4cCI6MTc1Njk1MTQ2NCwiYXVkIjoic29uYS1hcHAiLCJpc3MiOiJzb25hLWFwaSJ9.IBjvrFbnDt9TsrpbLo1Vdv_9RitwYp8KiULDJ2vxY2M", forKey: "DEMO_ACCESS_TOKEN")
            }
    
    private func onGetToken(){
        guard let token = shared?.string(forKey: "DEMO_ACCESS_TOKEN") else {
            return
        }
        self.token = token
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Text(token)
                .bold()
            Button {
                onSaveToken()
                print("Save token")
            } label: {
                Text("Save Token")
            }
            
            Button {
                onGetToken()
                print("Get token")
            } label: {
                Text("Get Token")
            }

//            Spacer()
//            KeyboardApp()
        }
    }
}

#Preview {
    ContentView()
        .frame(height: 300)
        .loadCustomFonts()
}

#Preview("Text with Custom Font") {
    WText("New Font")
        .customFont(.zenLoopRegular, size: 30)
        .loadCustomFonts()
}
