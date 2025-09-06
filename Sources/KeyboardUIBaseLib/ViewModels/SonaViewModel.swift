//
//  SonaViewModel.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 23/8/25.
//

import SwiftUI

@MainActor
final class SonaViewModel: ObservableObject {
    private let sonaApiService: SonaApiServiceProtocol
    private let loadingVM: LoadingViewModel
    
    //@Published var input:String = "Hello I im Binhdadads"
    @Published private(set) var selectedTone: String = "" // Default tone
    @Published private(set) var selectedPersona: String = "" //Default persona
    @Published private(set) var conversationHistory: ConversationHistoryModel?
    
    
    init(sonaApiService: SonaApiServiceProtocol,loadingVM: LoadingViewModel) {
        self.sonaApiService = sonaApiService
        self.loadingVM = loadingVM
    }
    
    func rewriteText(_ data: RewriteRequestParam) async throws -> RewriteDataModel {
        do {
            // Validate input data using RewriteValidator
            try RewriteValidator.validate(data)
            loadingVM.startLoading()
            let response =  try await sonaApiService.rewriteApi(data)
            let data = RewriteDataModel(from: response)
            loadingVM.stopLoading()
            return data
        } catch {
            loadingVM.stopLoading()
            throw error // Re-throw validation or API errors
        }
    }
    
    func proofreadText(_ data: ProofreadRequestParam) async throws -> ProofreadDataModel {
        do {
            try ProofreadValidator.validate(data)
            loadingVM.startLoading()
            let response =  try await sonaApiService.proofreadApi(data)
            let data = ProofreadDataModel(from: response)
            loadingVM.stopLoading()
            return data
        } catch {
            loadingVM.stopLoading()
            throw error // Re-throw validation or API errors
        }
    }
    
    func getConversation(for type: ConversationType, data: ConversationRequestParam) async throws -> ConversationDataModel {
        do {
            loadingVM.startLoading()
            let response =  try await sonaApiService.getConversationApi(for: type, data: data)
            let data = ConversationDataModel(from: response)
            loadingVM.stopLoading()
            return data
        } catch {
            loadingVM.stopLoading()
            throw error // Re-throw validation or API errors
        }
    }
    
    func selectTone(_ tone: String) {
        self.selectedTone = tone
    }
    
    func selectPersona(_ persona: String) {
        self.selectedPersona = persona
    }
    
    func saveConversationHistory(_ data: Any){
        var history: ConversationHistoryModel?
        // Save the transaction history
        if let rewriteData = data as? RewriteDataModel {
            let conversation = rewriteData
            let output = conversation.output
            let conversationId = conversation.conversationId
            let promptOutputId = conversation.outputId
            let hasNext = conversation.hasNext
            let hasPrevious = conversation.hasPrevious
            let isFirst = conversation.isFirst
            let isLast = conversation.isLast
            
            history = ConversationHistoryModel(output:output, conversationId: conversationId, promptOutputId: promptOutputId, hasNext: hasNext, hasPrevious: hasPrevious, isFirst: isFirst, isLast: isLast)
        }
       
        if let proofreadData = data as? ProofreadDataModel {
            let conversation = proofreadData
            let output = conversation.output
            let conversationId = conversation.conversationId
            let promptOutputId = conversation.outputId
            let hasNext = conversation.hasNext
            let hasPrevious = conversation.hasPrevious
            let isFirst = conversation.isFirst
            let isLast = conversation.isLast
            
            history = ConversationHistoryModel(output: output, conversationId: conversationId, promptOutputId: promptOutputId, hasNext: hasNext, hasPrevious: hasPrevious, isFirst: isFirst, isLast: isLast)
        }
        if let conversationData = data as? ConversationDataModel {
            let conversation = conversationData
            let output = conversation.output
            let conversationId = conversation.conversationId
            let promptOutputId = conversation.outputId
            let hasNext = conversation.hasNext
            let hasPrevious = conversation.hasPrevious
            let isFirst = conversation.isFirst
            let isLast = conversation.isLast
            
            history = ConversationHistoryModel(output: output, conversationId: conversationId, promptOutputId: promptOutputId, hasNext: hasNext, hasPrevious: hasPrevious, isFirst: isFirst, isLast: isLast)
        }

        // You can store this history in a list or database as needed
        self.conversationHistory = history
    }
}
