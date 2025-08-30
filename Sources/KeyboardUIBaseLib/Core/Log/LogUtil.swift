//
//  LogUtil.swift
//  KeyboardUIBaseLib
//
//  Created by Thien Tran-Quan on 30/8/25.
//

import Foundation

public enum LogLevel: Int, CaseIterable {
    case verbose = 0
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4
    case none = 5
    
    var prefix: String {
        switch self {
        case .verbose: return "👀"
        case .debug: return "🐛"
        case .info: return "📍"
        case .warning: return "☹️"
        case .error: return "👿"
        case .none: return ""
        }
    }
    
    var name: String {
        switch self {
        case .verbose: return "VERBOSE"
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .warning: return "WARNING"
        case .error: return "ERROR"
        case .none: return "NONE"
        }
    }
}

public final class LogUtil {
    // Configuration
     static let isEnabled: Bool = true
     static let showTimestamp: Bool = false
     static let showLogLevel: Bool = true
     static let showTag: Bool = true
    
    // Tag filtering
    private static let skipTags: Set<String> = LogTagEnum.skipTags
        
    // MARK: - Public Logging Methods
    public static func v(_ tag: String, _ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .verbose, tag: tag, message: message, file: file, function: function, line: line)
    }
    
    public static func v(_ tag: LogTagEnum, _ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .verbose, tag: tag.rawValue, message: message, file: file, function: function, line: line)
    }
    
    public static func d(_ tag: String, _ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .debug, tag: tag, message: message, file: file, function: function, line: line)
    }
    
    public static func d(_ tag: LogTagEnum, _ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .debug, tag: tag.rawValue, message: message, file: file, function: function, line: line)
    }
    
    public static func i(_ tag: String, _ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .info, tag: tag, message: message, file: file, function: function, line: line)
    }
    
    public static func i(_ tag: LogTagEnum, _ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .info, tag: tag.rawValue, message: message, file: file, function: function, line: line)
    }
    
    public static func w(_ tag: String, _ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .warning, tag: tag, message: message, file: file, function: function, line: line)
    }
    
    public static func w(_ tag: LogTagEnum, _ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .warning, tag: tag.rawValue, message: message, file: file, function: function, line: line)
    }
    
    public static func e(_ tag: String, _ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .error, tag: tag, message: message, file: file, function: function, line: line)
    }
    
    public static func e(_ tag: LogTagEnum, _ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .error, tag: tag.rawValue, message: message, file: file, function: function, line: line)
    }
    
    // MARK: - Core Logging Method
    private static func log(level: LogLevel, tag: String, message: String, file: String, function: String, line: Int) {
        guard isEnabled else { return }
        
        // Check if tag should be skipped
        guard shouldLogTag(tag) else { return }
        // Perform logging directly since we're on main actor
        performLog(level: level, tag: tag, message: message, file: file, function: function, line: line)
    }
    
    private static func shouldLogTag(_ tag: String) -> Bool {
        // If tag is in skip list, don't log
        if skipTags.contains(tag) {
            return false
        }
        
        return true
    }
    
    private static func performLog(level: LogLevel, tag: String, message: String, file: String, function: String, line: Int) {
        var timestamp = ""
        if showTimestamp {
            let dateFormatter: DateFormatter = DateFormatter()
    
                   dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
                   dateFormatter.timeZone = TimeZone.current

            timestamp = "[\(dateFormatter.string(from: Date()))] "
        }
        
        //let levelPrefix = showLogLevel ? "\(level.prefix) [\(level.name)] " : ""
        let levelPrefix = showLogLevel ? "\(level.prefix) ::: " : ""
        let tagInfo = showTag ? "[\(tag)] ::: " : ""
//        let fileName = URL(fileURLWithPath: file).lastPathComponent
//        let location = "[\(fileName):\(line) \(function)]"
        
        //let logMessage = "\(timestamp)\(levelPrefix)\(tagInfo)\(location) \(message)"
        let logMessage = "\(timestamp)\(levelPrefix)\(tagInfo)\(message)"
        // Print to console only
        print(logMessage)
    }
}
