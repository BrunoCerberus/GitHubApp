//
//  LogManager.swift
//  GitHubApp
//
//  Created on 2025-10-11.
//

import Foundation
import os.log

/// Centralized logging manager that wraps os.log with severity levels
/// Logs are only active in DEBUG builds and automatically excluded from production
final class LogManager {
    static let shared = LogManager()

    private let subsystem = Bundle.main.bundleIdentifier ?? "com.githubapp.app"

    // MARK: - Log Categories

    private enum Category: String {
        case general = "General"
        case network = "Network"
        case database = "Database"
        case ui = "UI"
        case domain = "Domain"
        case viewModel = "ViewModel"
        case service = "Service"
    }

    private init() {}

    // MARK: - Public Logging Methods

    /// Log debug information (verbose, development only)
    func debug(_ message: String, category: String = "General", file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, category: category, file: file, function: function, line: line)
    }

    /// Log informational messages
    func info(_ message: String, category: String = "General", file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, category: category, file: file, function: function, line: line)
    }

    /// Log warnings (potential issues)
    func warning(_ message: String, category: String = "General", file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .default, category: category, file: file, function: function, line: line)
    }

    /// Log errors (actual problems)
    func error(_ message: String, category: String = "General", file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, category: category, file: file, function: function, line: line)
    }

    /// Log critical issues (severe problems requiring immediate attention)
    func critical(_ message: String, category: String = "General", file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .fault, category: category, file: file, function: function, line: line)
    }

    // MARK: - Specialized Category Methods

    func network(_ message: String, level: LogLevel = .info) {
        log(message, level: level.osLogType, category: "Network")
    }

    func database(_ message: String, level: LogLevel = .info) {
        log(message, level: level.osLogType, category: "Database")
    }

    func ui(_ message: String, level: LogLevel = .info) {
        log(message, level: level.osLogType, category: "UI")
    }

    func domain(_ message: String, level: LogLevel = .info) {
        log(message, level: level.osLogType, category: "Domain")
    }

    func viewModel(_ message: String, level: LogLevel = .info) {
        log(message, level: level.osLogType, category: "ViewModel")
    }

    func service(_ message: String, level: LogLevel = .info) {
        log(message, level: level.osLogType, category: "Service")
    }

    // MARK: - Private Implementation

    private func log(_ message: String, level: OSLogType, category: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
            let logger = Logger(subsystem: subsystem, category: category)
            let fileName = (file as NSString).lastPathComponent
            let formattedMessage = "[\(fileName):\(line)] \(function) - \(message)"

            switch level {
            case .debug:
                logger.debug("\(formattedMessage)")
            case .info:
                logger.info("\(formattedMessage)")
            case .default:
                logger.warning("\(formattedMessage)")
            case .error:
                logger.error("\(formattedMessage)")
            case .fault:
                logger.critical("\(formattedMessage)")
            default:
                logger.log("\(formattedMessage)")
            }
        #endif
    }
}

// MARK: - Log Level Enum

enum LogLevel {
    case debug
    case info
    case warning
    case error
    case critical

    var osLogType: OSLogType {
        switch self {
        case .debug: .debug
        case .info: .info
        case .warning: .default
        case .error: .error
        case .critical: .fault
        }
    }
}

// MARK: - Convenience Global Functions (Optional)

#if DEBUG
    /// Global convenience function for quick debug logging
    func logDebug(_ message: String, category: String = "General") {
        LogManager.shared.debug(message, category: category)
    }

    func logInfo(_ message: String, category: String = "General") {
        LogManager.shared.info(message, category: category)
    }

    func logWarning(_ message: String, category: String = "General") {
        LogManager.shared.warning(message, category: category)
    }

    func logError(_ message: String, category: String = "General") {
        LogManager.shared.error(message, category: category)
    }
#endif
