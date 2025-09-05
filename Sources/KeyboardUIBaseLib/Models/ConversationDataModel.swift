//
//  ProofreadDataModel.swift
//  Pods
//
//  Created by Thien Tran-Quan on 5/9/25.
//

import Foundation

struct ConversationDataModel {
    let output: String
    let promptUsed: String
    let version: String
    let conversationId: String
    let outputId: String
    
    init(from response: ConversationDataResponse) {
        self.output = response.result.conversation.output
        self.promptUsed = response.result.conversation.promptUsed
        self.version = response.result.conversation.version
        self.conversationId = response.result.conversation.conversationID
        self.outputId = response.result.conversation.outputID
    }
}
