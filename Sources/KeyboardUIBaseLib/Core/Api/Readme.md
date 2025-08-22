// MARK: - Usage Examples
// Basic Request
/_
do {
let response: BaseResponse<[User]> = try await ApiBase.shared.request(
url: "https://api.example.com/users",
method: .get
)
if response.success {
print("Users:", response.data)
} else {
print("Error:", response.message ?? "Unknown error")
}
} catch {
print("Request error:", error)
}
_/

// Authenticated Request
/_
do {
let token = "your_token_here"
let response: BaseResponse<[Post]> = try await ApiBase.shared.requestWithAuth(
url: "https://api.example.com/posts/my",
method: .get,
token: token
)
if response.success {
print("Posts:", response.data)
} else {
print("Error:", response.message ?? "Unknown error")
}
} catch {
print("Request error:", error)
}
_/

// Custom Request with Parameters
/_
do {
let parameters: [String: Any & Sendable] = [
"title": "New Post",
"content": "This is the post content"
]
let headers = [
"X-Client-Version": "1.0.0"
]
let response: BaseResponse<Post> = try await ApiBase.shared.request(
url: "https://api.example.com/posts",
method: .post,
parameters: parameters,
httpHeaders: headers,
encoding: JSONEncoding.default
)
if response.success {
print("Created Post:", response.data)
} else {
print("Error:", response.message ?? "Unknown error")
}
} catch {
print("Request error:", error)
}
_/
