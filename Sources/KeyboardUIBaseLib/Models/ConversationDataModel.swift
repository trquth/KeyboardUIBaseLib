//
//  ProofreadDataModel.swift
//  Pods
//
//  Created by Thien Tran-Quan on 5/9/25.
//

import Foundation

struct ConversationDataModel {
    let output, promptUsed, version, conversationId, outputId: String
    let hasNext, hasPrevious, isFirst, isLast: Bool

    init(from response: ConversationDataResponse) {
        self.output = response.result.conversation.output
        self.promptUsed = response.result.conversation.promptUsed
        self.version = response.result.conversation.version
        self.conversationId = response.result.conversation.conversationID
        self.outputId = response.result.conversation.outputID
        self.hasNext = response.result.hasNext
        self.hasPrevious = response.result.hasPrevious
        self.isFirst = response.result.isFirst
        self.isLast = response.result.isLast
    }
}
