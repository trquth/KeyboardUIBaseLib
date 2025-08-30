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

@MainActor
public final class LogUtil {
    // MARK: - Properties
    public static let shared = LogUtil()
    
    private let dateFormatter: DateFormatter
    
    // Configuration
    public var currentLogLevel: LogLevel = .debug
    public var isEnabled: Bool = true
    public var showTimestamp: Bool = false
    public var showLogLevel: Bool = true
    public var showTag: Bool = true
    
    // Tag filtering
    private var skipTags: Set<String> = []
    private var allowedTags: Set<String>? = nil // nil means allow all tags
    
    // MARK: - Initialization
    private init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        dateFormatter.timeZone = TimeZone.current
        skipTags = LogTagEnum.skipTags
    }
    
    // MARK: - Public Logging Methods
    public static func v(_ tag: String, _ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.log(level: .verbose, tag: tag, message: message, file: file, function: function, line: line)
    }
    
    public static func v(_ tag: LogTagEnum, _ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.log(level: .verbose, tag: tag.rawValue, message: message, file: file, function: function, line: line)
    }
    
    public static func d(_ tag: String, _ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.log(level: .debug, tag: tag, message: message, file: file, function: function, line: line)
    }
    
    public static func d(_ tag: LogTagEnum, _ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.log(level: .debug, tag: tag.rawValue, message: message, file: file, function: function, line: line)
    }
    
    public static func i(_ tag: String, _ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.log(level: .info, tag: tag, message: message, file: file, function: function, line: line)
    }
    
    public static func i(_ tag: LogTagEnum, _ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.log(level: .info, tag: tag.rawValue, message: message, file: file, function: function, line: line)
    }
    
    public static func w(_ tag: String, _ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.log(level: .warning, tag: tag, message: message, file: file, function: function, line: line)
    }
    
    public static func w(_ tag: LogTagEnum, _ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.log(level: .warning, tag: tag.rawValue, message: message, file: file, function: function, line: line)
    }
    
    public static func e(_ tag: String, _ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.log(level: .error, tag: tag, message: message, file: file, function: function, line: line)
    }
    
    public static func e(_ tag: LogTagEnum, _ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.log(level: .error, tag: tag.rawValue, message: message, file: file, function: function, line: line)
    }
    
    // MARK: - Core Logging Method
    private func log(level: LogLevel, tag: String, message: String, file: String, function: String, line: Int) {
        guard isEnabled && level.rawValue >= currentLogLevel.rawValue else { return }
        
        // Check if tag should be skipped
        guard shouldLogTag(tag) else { return }
        
        // Perform logging directly since we're on main actor
        performLog(level: level, tag: tag, message: message, file: file, function: function, line: line)
    }
    
    private func shouldLogTag(_ tag: String) -> Bool {
        // If tag is in skip list, don't log
        if skipTags.contains(tag) {
            return false
        }
        
        // If allowed tags are specified and tag is not in the list, don't log
        if let allowedTags = allowedTags, !allowedTags.contains(tag) {
            return false
        }
        
        return true
    }
    
    private func performLog(level: LogLevel, tag: String, message: String, file: String, function: String, line: Int) {
        let timestamp = showTimestamp ? "[\(dateFormatter.string(from: Date()))] " : ""
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
    
    // MARK: - Configuration Methods
    public static func setLogLevel(_ level: LogLevel) {
        shared.currentLogLevel = level
    }
    
    public static func enable() {
        shared.isEnabled = true
    }
    
    public static func disable() {
        shared.isEnabled = false
    }
    
    public static func configure(
        level: LogLevel = .debug,
        enabled: Bool = true,
        showTimestamp: Bool = true,
        showLogLevel: Bool = true,
        showTag: Bool = true
    ) {
        shared.currentLogLevel = level
        shared.isEnabled = enabled
        shared.showTimestamp = showTimestamp
        shared.showLogLevel = showLogLevel
        shared.showTag = showTag
    }
    
    // MARK: - Tag Filtering Methods
    public static func skipTag(_ tag: String) {
        shared.skipTags.insert(tag)
    }
    
    public static func skipTag(_ tag: LogTagEnum) {
        shared.skipTags.insert(tag.rawValue)
    }
    
    public static func skipTags(_ tags: [String]) {
        for tag in tags {
            shared.skipTags.insert(tag)
        }
    }
    
    public static func skipTags(_ tags: [LogTagEnum]) {
        for tag in tags {
            shared.skipTags.insert(tag.rawValue)
        }
    }
    
    public static func allowTag(_ tag: String) {
        shared.skipTags.remove(tag)
    }
    
    public static func allowTag(_ tag: LogTagEnum) {
        shared.skipTags.remove(tag.rawValue)
    }
    
    public static func allowTags(_ tags: [String]) {
        for tag in tags {
            shared.skipTags.remove(tag)
        }
    }
    
    public static func allowTags(_ tags: [LogTagEnum]) {
        for tag in tags {
            shared.skipTags.remove(tag.rawValue)
        }
    }
    
    public static func setAllowedTags(_ tags: [String]) {
        shared.allowedTags = Set(tags)
    }
    
    public static func setAllowedTags(_ tags: [LogTagEnum]) {
        shared.allowedTags = Set(tags.map { $0.rawValue })
    }
    
    public static func clearAllowedTags() {
        shared.allowedTags = nil
    }
    
    public static func clearSkippedTags() {
        shared.skipTags.removeAll()
    }
    
    public static func getSkippedTags() -> Set<String> {
        return shared.skipTags
    }
    
    public static func getAllowedTags() -> Set<String>? {
        return shared.allowedTags
    }
    
    // MARK: - Convenience Methods with LogTagEnum
    public static func log(_ level: LogLevel, _ tag: LogTagEnum, _ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.log(level: level, tag: tag.rawValue, message: message, file: file, function: function, line: line)
    }
    
    public static func log(_ level: LogLevel, _ tag: String, _ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.log(level: level, tag: tag, message: message, file: file, function: function, line: line)
    }
    
    // MARK: - Bulk Operations with LogTagEnum
    public static func skipAllDefaultTags() {
        skipTags(Array(LogTagEnum.skipTags))
    }
    
    public static func allowOnlyEnumTags() {
        let allEnumTags = LogTagEnum.allCases.map { $0.rawValue }
        setAllowedTags(allEnumTags)
    }
}
