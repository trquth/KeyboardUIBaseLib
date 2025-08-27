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
    func proofreadApi(_ data: ProofreadRequestParam) async throws -> ProofreadDataResponse
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
                httpHeaders: ["Authorization" :" Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2OGFjMmU4YmQwZWUxMzIwMDMzZTVjMTgiLCJpYXQiOjE3NTYxOTk0MzQsImV4cCI6MTc1NjgwNDIzNCwiYXVkIjoic29uYS1hcHAiLCJpc3MiOiJzb25hLWFwaSJ9.TeUktzu7TKwXcHj-jw5pLU5gwV1IHHlIlDklNEu9KB8"],
                encoding: JSONEncoding.default
            )
            return response.data
        } catch {
            print("Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    //    curl --location 'https://pr0lkn29o9.execute-api.us-east-1.amazonaws.com/Prod/api/proofread' \
    //    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2OGFjMmU4YmQwZWUxMzIwMDMzZTVjMTgiLCJpYXQiOjE3NTYxOTk0MzQsImV4cCI6MTc1NjgwNDIzNCwiYXVkIjoic29uYS1hcHAiLCJpc3MiOiJzb25hLWFwaSJ9.TeUktzu7TKwXcHj-jw5pLU5gwV1IHHlIlDklNEu9KB8' \
    //    --header 'Content-Type: application/json' \
    //    --data '{
    //        "message": "Hello I im Binh",
    //        "type": "proofread",
    //        "version": "proofread-v1"
    //    }'
    func proofreadApi(_ data: ProofreadRequestParam) async throws -> ProofreadDataResponse {
        do {
            let params: [String: Any & Sendable] = [
                "message": data.message,
                "type": data.type,
                "version": data.version
            ]
            let url = "\(API_BASE_URL)/Prod/api/proofread"
            let response: BaseResponse<ProofreadDataResponse> = try await ApiBase.shared.request(
                url: url,
                method: .post,
                parameters: params,
                httpHeaders: ["Authorization" :" Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2OGFjMmU4YmQwZWUxMzIwMDMzZTVjMTgiLCJpYXQiOjE3NTYxOTk0MzQsImV4cCI6MTc1NjgwNDIzNCwiYXVkIjoic29uYS1hcHAiLCJpc3MiOiJzb25hLWFwaSJ9.TeUktzu7TKwXcHj-jw5pLU5gwV1IHHlIlDklNEu9KB8"],
                encoding: JSONEncoding.default
            )
            return response.data
        } catch {
            print("Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    
}

