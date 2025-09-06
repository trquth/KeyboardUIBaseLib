//
//  ProofreadDataModel.swift
//  Pods
//
//  Created by Thien Tran-Quan on 5/9/25.
//

import Foundation

struct ProofreadDataModel {
    let output, promptUsed, version, conversationId, outputId: String
    let hasNext, hasPrevious, isFirst, isLast: Bool
    
    init(from response: ProofreadDataResponse){
        self.output = response.conversation.output
        self.promptUsed = response.conversation.promptUsed
        self.version = response.conversation.version
        self.conversationId = response.conversation.conversationID
        self.outputId = response.conversation.outputID
        self.hasNext = response.hasNext
        self.hasPrevious = response.hasPrevious
        self.isFirst = response.isFirst
        self.isLast = response.isLast
    }
}
