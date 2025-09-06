//
//  File.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 6/9/25.
//

import Foundation

struct ConversationHistoryModel {
    let output, conversationId, promptOutputId: String
    let hasNext, hasPrevious, isFirst, isLast: Bool

    init(output:String, conversationId: String, promptOutputId: String,hasNext: Bool = false, hasPrevious: Bool = false, isFirst: Bool = false, isLast: Bool = false) {
        self.output = output
        self.conversationId = conversationId
        self.promptOutputId = promptOutputId
        self.hasNext = hasNext
        self.hasPrevious = hasPrevious
        self.isFirst = isFirst
        self.isLast = isLast
    }
}
