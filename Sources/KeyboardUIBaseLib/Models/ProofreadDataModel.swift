//
//  ProofreadDataModel.swift
//  Pods
//
//  Created by Thien Tran-Quan on 5/9/25.
//

import Foundation

struct ProofreadDataModel {
    let output: String
    let promptUsed: String
    let version: String
    let conversationId: String
    let outputId: String
    
    init(from response: ProofreadDataResponse){
        self.output = response.conversation.output
        self.promptUsed = response.conversation.promptUsed
        self.version = response.conversation.version
        self.conversationId = response.conversation.conversationID
        self.outputId = response.conversation.outputID
    }
}
