////
////  ApiBaseExamples.swift
////  KeyboardUIBaseLib
////
////  Created by Assistant on 22/8/25.
////
//
//import Foundation
//import Alamofire
//
//// MARK: - Example Data Models
//
//struct User: Decodable {
//    let id: Int
//    let name: String
//    let email: String
//    let createdAt: String
//}
//
//struct Post: Decodable {
//    let id: Int
//    let title: String
//    let content: String
//    let userId: Int
//}
//
//struct LoginRequest: Encodable {
//    let email: String
//    let password: String
//}
//
//struct LoginResponse: Decodable {
//    let token: String
//    let user: User
//    let expiresAt: String
//}
//
//struct CreatePostRequest: Encodable {
//    let title: String
//    let content: String
//}
//
//// MARK: - ApiBase Usage Examples
//
//class ApiExamples {
//    
//    // MARK: - GET Request Examples
//    
//    /// Example 1: Simple GET request
//    func fetchUsers() async {
//        do {
//            let response: BaseResponse<[User]> = try await ApiBase.shared.request(
//                url: "https://api.example.com/users",
//                method: .get
//            )
//            
//            if response.success {
//                print("✅ Users fetched successfully:")
//                response.data.forEach { user in
//                    print("- \(user.name) (\(user.email))")
//                }
//            } else {
//                print("❌ Failed to fetch users: \(response.message ?? "Unknown error")")
//            }
//            
//        } catch {
//            print("❌ Error fetching users: \(error)")
//        }
//    }
//    
//    /// Example 2: GET request with query parameters
//    func searchUsers(query: String, page: Int = 1) async {
//        do {
//            let parameters = [
//                "q": query,
//                "page": page,
//                "limit": 10
//            ] as [String: Any & Sendable]
//            
//            let response: BaseResponse<[User]> = try await ApiBase.shared.request(
//                url: "https://api.example.com/users/search",
//                method: .get,
//                parameters: parameters
//            )
//            
//            if response.success {
//                print("✅ Found \(response.data.count) users matching '\(query)'")
//            }
//            
//        } catch {
//            print("❌ Search error: \(error)")
//        }
//    }
//    
//    /// Example 3: GET request with custom headers
//    func fetchUserProfile() async {
//        do {
//            let customHeaders = [
//                "X-Client-Version": "1.0.0",
//                "X-Platform": "iOS"
//            ]
//            
//            let response: BaseResponse<User> = try await ApiBase.shared.request(
//                url: "https://api.example.com/profile",
//                method: .get,
//                httpHeaders: customHeaders
//            )
//            
//            if response.success {
//                print("✅ Profile: \(response.data.name)")
//            }
//            
//        } catch {
//            print("❌ Profile error: \(error)")
//        }
//    }
//    
//    // MARK: - POST Request Examples
//    
//    /// Example 4: POST request with JSON body
//    func login(email: String, password: String) async {
//        do {
//            let loginData = [
//                "email": email,
//                "password": password
//            ] as [String: Any & Sendable]
//            
//            let response: BaseResponse<LoginResponse> = try await ApiBase.shared.request(
//                url: "https://api.example.com/auth/login",
//                method: .post,
//                parameters: loginData,
//                encoding: JSONEncoding.default
//            )
//            
//            if response.success {
//                let token = response.data.token
//                print("✅ Login successful! Token: \(token)")
//                
//                // Store token for future requests
//                UserDefaults.standard.set(token, forKey: "auth_token")
//            }
//            
//        } catch ApiError.http(let statusCode, _) {
//            if statusCode == 401 {
//                print("❌ Invalid credentials")
//            } else {
//                print("❌ Login failed with status: \(statusCode)")
//            }
//        } catch {
//            print("❌ Login error: \(error)")
//        }
//    }
//    
//    /// Example 5: POST request to create resource
//    func createPost(title: String, content: String) async {
//        do {
//            let postData = [
//                "title": title,
//                "content": content
//            ] as [String: Any & Sendable]
//            
//            let response: BaseResponse<Post> = try await ApiBase.shared.request(
//                url: "https://api.example.com/posts",
//                method: .post,
//                parameters: postData,
//                encoding: JSONEncoding.default
//            )
//            
//            if response.success {
//                print("✅ Post created with ID: \(response.data.id)")
//            }
//            
//        } catch {
//            print("❌ Failed to create post: \(error)")
//        }
//    }
//    
//    // MARK: - Authenticated Request Examples
//    
//    /// Example 6: GET request with authentication
//    func fetchProtectedData() async {
//        do {
//            guard let token = UserDefaults.standard.string(forKey: "auth_token") else {
//                print("❌ No auth token found")
//                return
//            }
//            
//            let response: BaseResponse<[Post]> = try await ApiBase.shared.requestWithAuth(
//                url: "https://api.example.com/posts/my",
//                method: .get,
//                token: token
//            )
//            
//            if response.success {
//                print("✅ Fetched \(response.data.count) user posts")
//            }
//            
//        } catch ApiError.http(let statusCode, _) {
//            if statusCode == 401 {
//                print("❌ Token expired, need to re-login")
//                // Handle token refresh or redirect to login
//            }
//        } catch {
//            print("❌ Error: \(error)")
//        }
//    }
//    
//    /// Example 7: PUT request with authentication
//    func updatePost(postId: Int, title: String, content: String) async {
//        do {
//            guard let token = UserDefaults.standard.string(forKey: "auth_token") else {
//                print("❌ No auth token found")
//                return
//            }
//            
//            let updateData = [
//                "title": title,
//                "content": content
//            ] as [String: Any & Sendable]
//            
//            let response: BaseResponse<Post> = try await ApiBase.shared.requestWithAuth(
//                url: "https://api.example.com/posts/\(postId)",
//                method: .put,
//                parameters: updateData,
//                token: token,
//                encoding: JSONEncoding.default
//            )
//            
//            if response.success {
//                print("✅ Post updated successfully")
//            }
//            
//        } catch {
//            print("❌ Failed to update post: \(error)")
//        }
//    }
//    
//    /// Example 8: DELETE request with authentication
//    func deletePost(postId: Int) async {
//        do {
//            guard let token = UserDefaults.standard.string(forKey: "auth_token") else {
//                print("❌ No auth token found")
//                return
//            }
//            
//            // For DELETE requests, we might get an empty response
//            let response: BaseResponse<EmptyResponse> = try await ApiBase.shared.requestWithAuth(
//                url: "https://api.example.com/posts/\(postId)",
//                method: .delete,
//                token: token
//            )
//            
//            if response.success {
//                print("✅ Post deleted successfully")
//            }
//            
//        } catch {
//            print("❌ Failed to delete post: \(error)")
//        }
//    }
//    
//    // MARK: - Error Handling Examples
//    
//    /// Example 9: Comprehensive error handling
//    func fetchDataWithErrorHandling() async {
//        do {
//            let response: BaseResponse<[User]> = try await ApiBase.shared.request(
//                url: "https://api.example.com/users",
//                method: .get,
//                timeout: 15.0 // Custom timeout
//            )
//            
//            if response.success {
//                print("✅ Data fetched successfully")
//            } else {
//                print("⚠️ Request completed but not successful: \(response.message ?? "")")
//            }
//            
//        } catch ApiError.invalidURL {
//            print("❌ Invalid URL provided")
//        } catch ApiError.timeout {
//            print("❌ Request timed out")
//        } catch ApiError.networkUnavailable {
//            print("❌ No internet connection")
//        } catch ApiError.http(let statusCode, let data) {
//            print("❌ HTTP Error \(statusCode)")
//            if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
//                print("Error details: \(errorMessage)")
//            }
//        } catch ApiError.decoding(let error) {
//            print("❌ Failed to decode response: \(error)")
//        } catch {
//            print("❌ Unexpected error: \(error)")
//        }
//    }
//    
//    // MARK: - SwiftUI Integration Example
//    
//    /// Example 10: Using with SwiftUI and @MainActor
//    @MainActor
//    func fetchUsersForUI() async {
//        do {
//            let response: BaseResponse<[User]> = try await ApiBase.shared.request(
//                url: "https://api.example.com/users",
//                method: .get
//            )
//            
//            if response.success {
//                // Update UI on main thread
//                // self.users = response.data
//                print("✅ UI updated with \(response.data.count) users")
//            }
//            
//        } catch {
//            // Show error to user
//            print("❌ Error for UI: \(error.localizedDescription)")
//        }
//    }
//}
//
//// MARK: - Helper Models
//
//struct EmptyResponse: Decodable {
//    // Empty struct for endpoints that return no data
//}
//
//// MARK: - Usage in SwiftUI View
//
///*
//struct ContentView: View {
//    @State private var users: [User] = []
//    @State private var isLoading = false
//    @State private var errorMessage: String?
//    
//    var body: some View {
//        NavigationView {
//            List(users, id: \.id) { user in
//                VStack(alignment: .leading) {
//                    Text(user.name).font(.headline)
//                    Text(user.email).font(.caption).foregroundColor(.gray)
//                }
//            }
//            .navigationTitle("Users")
//            .task {
//                await loadUsers()
//            }
//        }
//    }
//    
//    private func loadUsers() async {
//        isLoading = true
//        errorMessage = nil
//        
//        do {
//            let response: BaseResponse<[User]> = try await ApiBase.shared.request(
//                url: "https://api.example.com/users",
//                method: .get
//            )
//            
//            if response.success {
//                users = response.data
//            } else {
//                errorMessage = response.message
//            }
//            
//        } catch {
//            errorMessage = error.localizedDescription
//        }
//        
//        isLoading = false
//    }
//}
//*/
