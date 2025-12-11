//
//  LoggerTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import Testing

/// Unit tests for Logger.
///
/// Tests cover:
/// - LogLevel enum conversion to OSLogType
/// - Singleton pattern
@MainActor
struct LoggerTests {
    // MARK: - Singleton Tests

    @Test("Logger shared instance is singleton")
    func loggerSharedInstanceIsSingleton() {
        let logger1 = Logger.shared
        let logger2 = Logger.shared
        #expect(logger1 === logger2, "Should be the same instance")
    }

    // MARK: - LogLevel Enum Tests

    @Test("LogLevel debug converts to correct OSLogType")
    func logLevelDebugConvertsToCorrectOSLogType() {
        let level = LogLevel.debug
        #expect(level.osLogType == .debug, "Debug should map to .debug OSLogType")
    }

    @Test("LogLevel info converts to correct OSLogType")
    func logLevelInfoConvertsToCorrectOSLogType() {
        let level = LogLevel.info
        #expect(level.osLogType == .info, "Info should map to .info OSLogType")
    }

    @Test("LogLevel warning converts to correct OSLogType")
    func logLevelWarningConvertsToCorrectOSLogType() {
        let level = LogLevel.warning
        #expect(level.osLogType == .default, "Warning should map to .default OSLogType")
    }

    @Test("LogLevel error converts to correct OSLogType")
    func logLevelErrorConvertsToCorrectOSLogType() {
        let level = LogLevel.error
        #expect(level.osLogType == .error, "Error should map to .error OSLogType")
    }

    @Test("LogLevel critical converts to correct OSLogType")
    func logLevelCriticalConvertsToCorrectOSLogType() {
        let level = LogLevel.critical
        #expect(level.osLogType == .fault, "Critical should map to .fault OSLogType")
    }
}
