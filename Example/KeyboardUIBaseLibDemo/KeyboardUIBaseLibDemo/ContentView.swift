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
    @State var input: String = ""
    @FocusState private var isFocused: Bool
    
    
    private func onSaveToken(){
        shared?.set("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2OGFjMmU4YmQwZWUxMzIwMDMzZTVjMTgiLCJpYXQiOjE3NTYzNDY2NjQsImV4cCI6MTc1Njk1MTQ2NCwiYXVkIjoic29uYS1hcHAiLCJpc3MiOiJzb25hLWFwaSJ9.IBjvrFbnDt9TsrpbLo1Vdv_9RitwYp8KiULDJ2vxY2M", forKey: "DEMO_ACCESS_TOKEN")
    }
    
    private func onGetToken(){
        guard let token = shared?.string(forKey: "DEMO_ACCESS_TOKEN") else {
            return
        }
        self.token = token
    }
    
    private func onClearToken(){
        shared?.removeObject(forKey: "DEMO_ACCESS_TOKEN")
        self.token = ""
    }
    
    var body: some View {
        ZStack {
            Color(.white)
                .ignoresSafeArea()
                .onTapGesture {
                    print("Tap background")
                    isFocused = false // dismiss keyboard
                }
            VStack(spacing: 25) {
                Text(token.isEmpty ? "No token" : token)
                    .bold()
                HStack(spacing: 15) {
                    Button {
                        onSaveToken()
                        print("Save token")
                    } label: {
                        Text("Save Token")
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 10).fill(.blue))
                    }
                    
                    Button {
                        onGetToken()
                        print("Get token")
                    } label: {
                        Text("Get Token")
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 10).fill(.green))
                    }
                    
                    Button {
                        onClearToken()
                        print("Clear token")
                    } label: {
                        Text("Clear Token")
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 10).fill(.red))
                    }
                }
                TextEditor(text: $input)
                .frame(height: 150)
                .focused($isFocused)
                .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1) // border color & width
                    )
                    .padding(.horizontal)
                
            }
        }
    }
}

#Preview {
    ContentView()
    //        .frame(height: 300)
        .loadCustomFonts()
}

#Preview("Text with Custom Font") {
    WText("New Font")
        .customFont(.zenLoopRegular, size: 30)
        .loadCustomFonts()
}
