//
//  RewriteModel.swift
//  Pods
//
//  Created by Thien Tran-Quan on 5/9/25.
//

import Foundation

struct RewriteDataModel {
    let output: String
    let promptUsed: String
    let version: String
    let conversationId: String
    let outputId: String

    init(from response: RewriteDataResponse) {
        self.output = response.conversation.output
        self.promptUsed = response.conversation.promptUsed
        self.version = response.conversation.version
        self.conversationId = response.conversation.conversationID
        self.outputId = response.conversation.outputID
    }
}
