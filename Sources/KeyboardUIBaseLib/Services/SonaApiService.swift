//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 23/8/25.
//

import Foundation
import Alamofire

// MARK: - Request Models


@MainActor
protocol SonaApiServiceProtocol {
    func rewriteApi(_ data: RewriteRequestParam) async throws -> RewriteDataResponse
}

class SonaApiService: SonaApiServiceProtocol {
    
    //    curl --location 'https://pr0lkn29o9.execute-api.us-east-1.amazonaws.com/Prod/api/rewrite' \
    //    --header 'Content-Type: application/json' \
    //    --data '{
    //        "message": "Hello I im Binhdadads",
    //        "type": "rewrite",
    //        "tone": "Neutral ",
    //        "persona": "Neutral",
    //        "version": "v1.0"
    //    }'
    func rewriteApi(_ data: RewriteRequestParam) async throws -> RewriteDataResponse {
        do {
            let params: [String: Any & Sendable] = [
                "message": data.message,
                "type": data.type,
                "tone": data.tone,
                "persona": data.persona,
                "version": data.version
            ]
            let url = "\(API_BASE_URL)/Prod/api/rewrite"
            let response: BaseResponse<RewriteDataResponse> = try await ApiBase.shared.request(
                url: url,
                method: .post,
                parameters: params,
                encoding: JSONEncoding.default
            )
            return response.data
        } catch {
            print("Error: \(error.localizedDescription)")
            throw error
        }
    }
}

