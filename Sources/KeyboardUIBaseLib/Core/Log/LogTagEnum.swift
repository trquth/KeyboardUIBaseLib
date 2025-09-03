//
//  LogTagEnum.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 30/8/25.
//

import Foundation

public enum LogTagEnum: String, CaseIterable {
    case NORMAL_KEYBOARD_VIEW = "NormalKeyboardView"
    case KEYBOARD_INPUT_VM = "KeyboardInputViewModel"
    case QUICK_TASKS_VIEW = "QuickTaskView"
    case Tone_And_Persona_View = "ToneAndPersonaView"
    
//    var tag: String {
//        switch self {
//        case .NORMAL_KEYBOARD_VIEW:
//            return "NormalKeyboardView"
//        }
//    }
    
    static var skipTags: Set<String> {
        let skipTags: [LogTagEnum] = []
        if( skipTags.isEmpty ) {
            return []
        }
        return Set(skipTags.map { $0.rawValue })
    }
}
