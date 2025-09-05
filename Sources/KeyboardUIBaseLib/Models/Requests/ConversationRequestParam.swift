//
//  ConversationRequestParam.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 27/8/25.
//

import Foundation

public struct ConversationRequestParam {
    let conversationId: String
    let promptOutputId: String
    
    init(conversationId: String, promptOutputId: String) {
        self.conversationId = conversationId
        self.promptOutputId = promptOutputId
    }
}
