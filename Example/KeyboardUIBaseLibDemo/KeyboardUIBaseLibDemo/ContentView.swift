//
//  ContentView.swift
//  KeyboardUIBaseLibDemo
//
//  Created by Thien Tran-Quan on 20/8/25.
//

import SwiftUI
import KeyboardUIBaseLib

// MARK: - RefreshTokenModel
struct RefreshTokenModel: Codable {
    let message: String
    let data: DataClass
}

// MARK: - DataClass
struct DataClass: Codable {
    let accessToken: String
}

struct ApiError: Error {
    let message: String
}

struct ContentView: View {
    
    private let shared = UserDefaults(suiteName: "group.keyboarduibaselib")
    private let REFRESH_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2OGE0M2FjMDgwZDU4ZDhhODg0NWJmODciLCJpYXQiOjE3NTY5NTYyMTQsImV4cCI6MTc1NzU2MTAxNCwiYXVkIjoic29uYS1hcHAiLCJpc3MiOiJzb25hLWFwaSJ9.b-0R9XgcTTL2vChikpQo-OhEmFtFA9oJiTnBghOYVgg"
    
    @State var token: String = ""
    @State var input: String = ""
    @FocusState private var isFocused: Bool
    
    @State var isLoading: Bool = false
    
    private func refreshTokenApi() async throws -> String{
        guard let url = URL(string: "https://pr0lkn29o9.execute-api.us-east-1.amazonaws.com/Prod/api/auth/refresh") else {
            throw ApiError(message: "Invalid URL")
        }
        isLoading = true
        var  request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "refreshToken": REFRESH_TOKEN
        ]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, _) = try await URLSession.shared.data(for: request)
        do {
            let token = try JSONDecoder().decode(RefreshTokenModel.self, from: data)
            isLoading = false
            return token.data.accessToken
        }catch {
            isLoading = false
            print("Decoding error: \(error.localizedDescription)")
            throw ApiError(message: "Decoding error")
        }
    }
    
    private func onSaveToken()async{
        do {
            let newToken = try await refreshTokenApi()
            shared?.set(newToken, forKey: "DEMO_ACCESS_TOKEN")
            self.token = newToken
        }catch {
            print("Error refreshing token: \(error.localizedDescription)")
        }
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
                        Task {
                           await onSaveToken()
                            print("Generate token")
                        }
                       
                    } label: {
                        Text(isLoading ? "Loading..." : "Generate Token")
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
