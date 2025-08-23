//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 23/8/25.
//

import Foundation
import Alamofire

struct Post: Decodable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

struct PostTest: Decodable {
    let title: String
    let body: String
    let userId: Int
    let id: Int
}

protocol SonaApiServiceProtocol {
    func rewrite() async throws -> RewriteDataResponse
}

class SonaApiService: SonaApiServiceProtocol {
   // private var apiBase: ApiBase;
    
    init() {
        //apiBase = ApiBase.shared
    }
    
    //    curl --location 'https://pr0lkn29o9.execute-api.us-east-1.amazonaws.com/Prod/api/rewrite' \
    //    --header 'Content-Type: application/json' \
    //    --data '{
    //        "message": "Hello I im Binhdadads",
    //        "type": "rewrite",
    //        "tone": "Neutral ",
    //        "persona": "Neutral",
    //        "version": "v1.0"
    //    }'
    @MainActor
    func rewrite() async throws -> RewriteDataResponse {
        do {
            let params:[String: Any & Sendable]  = [
                "message": "Hello I im Binhdadads",
                "type": "rewrite",
                "tone":"Neutral",
                "persona": "Neutral",
                "version": "v1.0"
            ]
            let url = "https://pr0lkn29o9.execute-api.us-east-1.amazonaws.com/Prod/api/rewrite"
            let response: BaseResponse<RewriteDataResponse> = try await ApiBase.shared.request(
                url: url,
                method: .post,
                parameters: params,
                httpHeaders: nil,
                encoding: JSONEncoding.default
            )
            return response.data
            // Handle response as needed
        } catch  {
            print("Error: \(error.localizedDescription)")
            throw error
        }
    }
  
    
//    func postExample() async{
//        do {
//            let url = "https://jsonplaceholder.typicode.com/posts"
//            let parameters: [String: Any & Sendable] = [
//                "title": "foo",
//                "body": "bar",
//                "userId": 1
//            ]
//            let response:  BaseResponse<PostTest> = try  await ApiBase.shared.request(
//                url: url,
//                method: .post,
//                parameters: parameters
//            )
//            
//        } catch  {
//            print("Error: \(error)")
//        }
//    }
}

