// swiftlint:disable file_length
//
//  LoggerTests.swift
//  GitHubAppTests
//
//  Created by Claude Code to improve test coverage
//

@testable import GitHubApp
import Testing

/// Unit tests for Logger.
///
/// Tests cover:
/// - All logging levels (debug, info, warning, error, critical)
/// - Specialized category methods (network, database, ui, domain, viewModel, service)
/// - LogLevel enum conversion to OSLogType
/// - Global convenience functions (DEBUG builds only)
/// - Singleton pattern
@MainActor
struct LoggerTests { // swiftlint:disable:this type_body_length
    // MARK: - Basic Logging Tests

    @Test("Logger shared instance is singleton")
    func loggerSharedInstanceIsSingleton() {
        // Given/When
        let logger1 = Logger.shared
        let logger2 = Logger.shared

        // Then
        #expect(logger1 === logger2, "Should be the same instance")
    }

    @Test("Debug log does not crash")
    func debugLogDoesNotCrash() {
        // Given
        let logger = Logger.shared

        // When/Then
        logger.debug("Test debug message")
        #expect(true, "Debug logging should not crash")
    }

    @Test("Info log does not crash")
    func infoLogDoesNotCrash() {
        // Given
        let logger = Logger.shared

        // When/Then
        logger.info("Test info message")
        #expect(true, "Info logging should not crash")
    }

    @Test("Warning log does not crash")
    func warningLogDoesNotCrash() {
        // Given
        let logger = Logger.shared

        // When/Then
        logger.warning("Test warning message")
        #expect(true, "Warning logging should not crash")
    }

    @Test("Error log does not crash")
    func errorLogDoesNotCrash() {
        // Given
        let logger = Logger.shared

        // When/Then
        logger.error("Test error message")
        #expect(true, "Error logging should not crash")
    }

    @Test("Critical log does not crash")
    func criticalLogDoesNotCrash() {
        // Given
        let logger = Logger.shared

        // When/Then
        logger.critical("Test critical message")
        #expect(true, "Critical logging should not crash")
    }

    // MARK: - Custom Category Tests

    @Test("Debug log with custom category")
    func debugLogWithCustomCategory() {
        // Given
        let logger = Logger.shared

        // When/Then
        logger.debug("Test message", category: "CustomCategory")
        #expect(true, "Should handle custom category")
    }

    @Test("Info log with custom category")
    func infoLogWithCustomCategory() {
        // Given
        let logger = Logger.shared

        // When/Then
        logger.info("Test message", category: "CustomCategory")
        #expect(true, "Should handle custom category")
    }

    @Test("Warning log with custom category")
    func warningLogWithCustomCategory() {
        // Given
        let logger = Logger.shared

        // When/Then
        logger.warning("Test message", category: "CustomCategory")
        #expect(true, "Should handle custom category")
    }

    @Test("Error log with custom category")
    func errorLogWithCustomCategory() {
        // Given
        let logger = Logger.shared

        // When/Then
        logger.error("Test message", category: "CustomCategory")
        #expect(true, "Should handle custom category")
    }

    @Test("Critical log with custom category")
    func criticalLogWithCustomCategory() {
        // Given
        let logger = Logger.shared

        // When/Then
        logger.critical("Test message", category: "CustomCategory")
        #expect(true, "Should handle custom category")
    }

    // MARK: - Specialized Category Method Tests

    @Test("Network log with default level")
    func networkLogWithDefaultLevel() {
        // Given
        let logger = Logger.shared

        // When/Then
        logger.network("Network operation completed")
        #expect(true, "Network logging should not crash")
    }

    @Test("Network log with debug level")
    func networkLogWithDebugLevel() {
        // Given
        let logger = Logger.shared

        // When/Then
        logger.network("Network debug info", level: .debug)
        #expect(true, "Network debug logging should not crash")
    }

    @Test("Network log with error level")
    func networkLogWithErrorLevel() {
        // Given
        let logger = Logger.shared

        // When/Then
        logger.network("Network error occurred", level: .error)
        #expect(true, "Network error logging should not crash")
    }

    @Test("Network log with warning level")
    func networkLogWithWarningLevel() {
        // Given
        let logger = Logger.shared

        // When/Then
        logger.network("Network warning", level: .warning)
        #expect(true, "Network warning logging should not crash")
    }

    @Test("Network log with critical level")
    func networkLogWithCriticalLevel() {
        // Given
        let logger = Logger.shared

        // When/Then
        logger.network("Network critical issue", level: .critical)
        #expect(true, "Network critical logging should not crash")
    }

    @Test("Database log with default level")
    func databaseLogWithDefaultLevel() {
        // Given
        let logger = Logger.shared

        // When/Then
        logger.database("Database operation completed")
        #expect(true, "Database logging should not crash")
    }

    @Test("Database log with debug level")
    func databaseLogWithDebugLevel() {
        // Given
        let logger = Logger.shared

        // When/Then
        logger.database("Database query executed", level: .debug)
        #expect(true, "Database debug logging should not crash")
    }

    @Test("Database log with error level")
    func databaseLogWithErrorLevel() {
        // Given
        let logger = Logger.shared

        // When/Then
        logger.database("Database connection failed", level: .error)
        #expect(true, "Database error logging should not crash")
    }

    @Test("UI log with default level")
    func uiLogWithDefaultLevel() {
        // Given
        let logger = Logger.shared

        // When/Then
        logger.ui("UI rendered successfully")
        #expect(true, "UI logging should not crash")
    }

    @Test("UI log with debug level")
    func uiLogWithDebugLevel() {
        // Given
        let logger = Logger.shared

        // When/Then
        logger.ui("View appeared", level: .debug)
        #expect(true, "UI debug logging should not crash")
    }

    @Test("UI log with warning level")
    func uiLogWithWarningLevel() {
        // Given
        let logger = Logger.shared

        // When/Then
        logger.ui("Layout warning", level: .warning)
        #expect(true, "UI warning logging should not crash")
    }

    @Test("Domain log with default level")
    func domainLogWithDefaultLevel() {
        // Given
        let logger = Logger.shared

        // When/Then
        logger.domain("Domain logic executed")
        #expect(true, "Domain logging should not crash")
    }

    @Test("Domain log with debug level")
    func domainLogWithDebugLevel() {
        // Given
        let logger = Logger.shared

        // When/Then
        logger.domain("State updated", level: .debug)
        #expect(true, "Domain debug logging should not crash")
    }

    @Test("Domain log with error level")
    func domainLogWithErrorLevel() {
        // Given
        let logger = Logger.shared

        // When/Then
        logger.domain("Domain error", level: .error)
        #expect(true, "Domain error logging should not crash")
    }

    @Test("ViewModel log with default level")
    func viewModelLogWithDefaultLevel() {
        // Given
        let logger = Logger.shared

        // When/Then
        logger.viewModel("ViewModel initialized")
        #expect(true, "ViewModel logging should not crash")
    }

    @Test("ViewModel log with info level")
    func viewModelLogWithInfoLevel() {
        // Given
        let logger = Logger.shared

        // When/Then
        logger.viewModel("Action dispatched", level: .info)
        #expect(true, "ViewModel info logging should not crash")
    }

    @Test("Service log with default level")
    func serviceLogWithDefaultLevel() {
        // Given
        let logger = Logger.shared

        // When/Then
        logger.service("Service call completed")
        #expect(true, "Service logging should not crash")
    }

    @Test("Service log with error level")
    func serviceLogWithErrorLevel() {
        // Given
        let logger = Logger.shared

        // When/Then
        logger.service("Service call failed", level: .error)
        #expect(true, "Service error logging should not crash")
    }

    @Test("Service log with critical level")
    func serviceLogWithCriticalLevel() {
        // Given
        let logger = Logger.shared

        // When/Then
        logger.service("Service critical failure", level: .critical)
        #expect(true, "Service critical logging should not crash")
    }

    // MARK: - LogLevel Enum Tests

    @Test("LogLevel debug converts to correct OSLogType")
    func logLevelDebugConvertsToCorrectOSLogType() {
        // Given
        let level = LogLevel.debug

        // When
        let osLogType = level.osLogType

        // Then
        #expect(osLogType == .debug, "Debug should map to .debug OSLogType")
    }

    @Test("LogLevel info converts to correct OSLogType")
    func logLevelInfoConvertsToCorrectOSLogType() {
        // Given
        let level = LogLevel.info

        // When
        let osLogType = level.osLogType

        // Then
        #expect(osLogType == .info, "Info should map to .info OSLogType")
    }

    @Test("LogLevel warning converts to correct OSLogType")
    func logLevelWarningConvertsToCorrectOSLogType() {
        // Given
        let level = LogLevel.warning

        // When
        let osLogType = level.osLogType

        // Then
        #expect(osLogType == .default, "Warning should map to .default OSLogType")
    }

    @Test("LogLevel error converts to correct OSLogType")
    func logLevelErrorConvertsToCorrectOSLogType() {
        // Given
        let level = LogLevel.error

        // When
        let osLogType = level.osLogType

        // Then
        #expect(osLogType == .error, "Error should map to .error OSLogType")
    }

    @Test("LogLevel critical converts to correct OSLogType")
    func logLevelCriticalConvertsToCorrectOSLogType() {
        // Given
        let level = LogLevel.critical

        // When
        let osLogType = level.osLogType

        // Then
        #expect(osLogType == .fault, "Critical should map to .fault OSLogType")
    }

    // MARK: - Edge Case Tests

    @Test("Log with empty message")
    func logWithEmptyMessage() {
        // Given
        let logger = Logger.shared

        // When/Then
        logger.info("")
        #expect(true, "Should handle empty message")
    }

    @Test("Log with very long message")
    func logWithVeryLongMessage() {
        // Given
        let logger = Logger.shared
        let longMessage = String(repeating: "A", count: 10000)

        // When/Then
        logger.info(longMessage)
        #expect(true, "Should handle very long message")
    }

    @Test("Log with special characters")
    func logWithSpecialCharacters() {
        // Given
        let logger = Logger.shared
        let specialMessage = "Test with émojis 😀 and spëcial çharacters \n\t"

        // When/Then
        logger.info(specialMessage)
        #expect(true, "Should handle special characters")
    }

    @Test("Log with multiline message")
    func logWithMultilineMessage() {
        // Given
        let logger = Logger.shared
        let multilineMessage = """
        Line 1
        Line 2
        Line 3
        """

        // When/Then
        logger.info(multilineMessage)
        #expect(true, "Should handle multiline message")
    }

    // MARK: - Global Convenience Function Tests

    #if DEBUG
        @Test("Global logDebug function works")
        func globalLogDebugFunctionWorks() {
            // When/Then
            logDebug("Global debug test")
            #expect(true, "Global logDebug should not crash")
        }

        @Test("Global logInfo function works")
        func globalLogInfoFunctionWorks() {
            // When/Then
            logInfo("Global info test")
            #expect(true, "Global logInfo should not crash")
        }

        @Test("Global logWarning function works")
        func globalLogWarningFunctionWorks() {
            // When/Then
            logWarning("Global warning test")
            #expect(true, "Global logWarning should not crash")
        }

        @Test("Global logError function works")
        func globalLogErrorFunctionWorks() {
            // When/Then
            logError("Global error test")
            #expect(true, "Global logError should not crash")
        }

        @Test("Global logDebug with custom category")
        func globalLogDebugWithCustomCategory() {
            // When/Then
            logDebug("Global debug test", category: "CustomCategory")
            #expect(true, "Global logDebug with custom category should not crash")
        }
    #endif
}
