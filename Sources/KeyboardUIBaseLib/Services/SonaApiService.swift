//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 23/8/25.
//

import Foundation
import Alamofire

// MARK: - Request Models

enum ConversationType: String {
    case back, forward
}

@MainActor
protocol SonaApiServiceProtocol {
    func rewriteApi(_ data: RewriteRequestParam) async throws -> RewriteDataResponse
    func proofreadApi(_ data: ProofreadRequestParam) async throws -> ProofreadDataResponse
    func getConversationApi(for type: ConversationType, data: ConversationRequestParam) async throws -> ConversationDataResponse
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
            let BASE_URL = ApiConfiguration.shared.baseUrl
            let params: [String: Any & Sendable] = [
                "message": data.message,
                "type": data.type,
                "tone": data.tone,
                "persona": data.persona,
                "version": data.version
            ]
            let url = "\(BASE_URL)/Prod/api/rewrite"
            let response: BaseResponse<RewriteDataResponse> = try await ApiBase.shared.requestWithAuth(
                url: url,
                method: .post,
                parameters: params,
                encoding: JSONEncoding.default
            )
            return response.data
        } catch {
            if let apiError = error as? ApiError {
                throw  ApiErrorConverter.convert(apiError)
            }
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
            let BASE_URL = ApiConfiguration.shared.baseUrl
            let params: [String: Any & Sendable] = [
                "message": data.message,
                "type": data.type,
                "version": data.version
            ]
            let url = "\(BASE_URL)/Prod/api/proofread"
            let response: BaseResponse<ProofreadDataResponse> = try await ApiBase.shared.requestWithAuth(
                url: url,
                method: .post,
                parameters: params,
                encoding: JSONEncoding.default
            )
            return response.data
        } catch {
            if let apiError = error as? ApiError {
                throw  ApiErrorConverter.convert(apiError)
            }
            throw error
        }
    }
    
//    curl -X GET --location 'https://pr0lkn29o9.execute-api.us-east-1.amazonaws.com/Prod/api/conversations/{conversationId}/nearby/{promptOutputId}?flag={back | forward}' \
//    --header 'Authorization: Bearer <access_token>'
    
//    curl --location 'https://pr0lkn29o9.execute-api.us-east-1.amazonaws.com/Prod/api/conversations/68ba8eb645cc8f37296c6638/nearby/68ba8f2b45cc8f37296c6646?flag=back' \
//    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2OGE0NTI5ZGU5OTQyMmM5ODkzOTM4MTUiLCJpYXQiOjE3NTcwNDQ3MDMsImV4cCI6MTc1NzY0OTUwMywiYXVkIjoic29uYS1hcHAiLCJpc3MiOiJzb25hLWFwaSJ9.iQ-1XQF1V3EDTjVzNtZUHYtaMidPhM-C-X4B-lBxgwQ'
  
    func getConversationApi(for type: ConversationType = .forward, data: ConversationRequestParam) async throws -> ConversationDataResponse {
        do {
            let BASE_URL = ApiConfiguration.shared.baseUrl
            let url = "\(BASE_URL)/Prod/api/conversations/\(data.conversationId)/nearby/\(data.promptOutputId)?flag=\(type.rawValue)"
            let response: BaseResponse<ConversationDataResponse> = try await ApiBase.shared.requestWithAuth(
                url: url,
                method: .get,
                parameters: nil,
                encoding: URLEncoding.default
            )
            return response.data
        } catch {
            if let apiError = error as? ApiError {
                throw  ApiErrorConverter.convert(apiError)
            }
            throw error
        }
    }
    
}

