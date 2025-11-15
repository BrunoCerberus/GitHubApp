//
//  TestUtilities.swift
//  GitHubAppTests
//
//  Provides utility functions for testing async state changes with proper waiting patterns.
//

import Combine
import Foundation
import SwiftUI
import Testing

// MARK: - Publisher Extensions

extension Publisher {
    func async() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = first()
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case let .failure(error):
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { value in
                        continuation.resume(returning: value)
                    }
                )
        }
    }
}

// MARK: - View Extensions

extension View {
    var wrappedViewController: UIViewController {
        UIHostingController(rootView: self)
    }
}

// MARK: - Test Errors

enum TestError: Error, CustomStringConvertible {
    case timeout(String)
    case conditionNotMet(String)

    var description: String {
        switch self {
        case let .timeout(message):
            "Test timeout: \(message)"
        case let .conditionNotMet(message):
            "Condition not met: \(message)"
        }
    }
}

// MARK: - Async State Polling

/**
 * Waits for a condition to become true by polling at regular intervals.
 *
 * This function is essential for testing MainActor-isolated async state changes
 * where the exact timing is unpredictable due to thread scheduling and Combine
 * pipeline propagation delays.
 *
 * - Parameters:
 *   - timeout: Maximum time to wait before throwing a timeout error (default: 2.0 seconds)
 *   - pollInterval: Time between condition checks in nanoseconds (default: 50ms)
 *   - description: Description of what we're waiting for (used in error messages)
 *   - condition: Closure that returns true when the desired state is reached
 *
 * - Throws: `TestError.timeout` if the condition doesn't become true within the timeout period
 *
 * - Example:
 * ```swift
 * // Wait for movies array to be populated
 * try await waitForCondition(description: "movies to load") {
 *     !viewModel.movies.isEmpty
 * }
 * ```
 */
func waitForCondition(
    timeout: TimeInterval = 2.0,
    pollInterval: UInt64 = 50_000_000, // 50ms
    description: String,
    condition: @escaping () -> Bool
) async throws {
    let deadline = Date().addingTimeInterval(timeout)

    // Yield to allow pending async work to complete before first check
    await Task.yield()

    while Date() < deadline {
        if condition() {
            return // Success!
        }
        try await Task.sleep(nanoseconds: pollInterval)
    }

    throw TestError.timeout("Timed out waiting for: \(description)")
}

/**
 * Waits for a condition to return a non-nil value by polling at regular intervals.
 *
 * This is useful when you need to wait for a specific state and also capture its value.
 *
 * - Parameters:
 *   - timeout: Maximum time to wait before throwing a timeout error (default: 2.0 seconds)
 *   - pollInterval: Time between condition checks in nanoseconds (default: 50ms)
 *   - description: Description of what we're waiting for (used in error messages)
 *   - condition: Closure that returns a non-nil value when the desired state is reached
 *
 * - Returns: The value returned by the condition closure when it first returns non-nil
 *
 * - Throws: `TestError.timeout` if the condition doesn't return non-nil within the timeout period
 *
 * - Example:
 * ```swift
 * // Wait for view state to become success and capture the data
 * let dataViewState = try await waitForValue(description: "success state") {
 *     if case let .success(data) = viewModel.viewState {
 *         return data
 *     }
 *     return nil
 * }
 * ```
 */
func waitForValue<T>(
    timeout: TimeInterval = 2.0,
    pollInterval: UInt64 = 50_000_000, // 50ms
    description: String,
    condition: @escaping () -> T?
) async throws -> T {
    let deadline = Date().addingTimeInterval(timeout)

    // Yield to allow pending async work to complete before first check
    await Task.yield()

    while Date() < deadline {
        if let value = condition() {
            return value
        }
        try await Task.sleep(nanoseconds: pollInterval)
    }

    throw TestError.timeout("Timed out waiting for: \(description)")
}

/**
 * Waits for a MainActor-isolated condition to become true.
 *
 * This variant ensures the condition is checked on the MainActor, which is necessary
 * when accessing @MainActor-isolated properties from test code.
 *
 * - Parameters:
 *   - timeout: Maximum time to wait before throwing a timeout error (default: 2.0 seconds)
 *   - pollInterval: Time between condition checks in nanoseconds (default: 50ms)
 *   - description: Description of what we're waiting for (used in error messages)
 *   - condition: MainActor-isolated closure that returns true when the desired state is reached
 *
 * - Throws: `TestError.timeout` if the condition doesn't become true within the timeout period
 *
 * - Example:
 * ```swift
 * // Wait for MainActor-isolated ViewModel property
 * try await waitForMainActorCondition(description: "movies to load") {
 *     !viewModel.movies.isEmpty
 * }
 * ```
 */
@MainActor
func waitForMainActorCondition(
    timeout: TimeInterval = 2.0,
    pollInterval: UInt64 = 50_000_000, // 50ms
    description: String,
    condition: @escaping @MainActor () -> Bool
) async throws {
    let deadline = Date().addingTimeInterval(timeout)

    // Yield to allow pending MainActor work to complete before first check
    await Task.yield()

    while Date() < deadline {
        if condition() {
            return
        }
        try await Task.sleep(nanoseconds: pollInterval)
    }

    throw TestError.timeout("Timed out waiting for: \(description)")
}

/**
 * Waits for a MainActor-isolated condition to return a non-nil value.
 *
 * - Parameters:
 *   - timeout: Maximum time to wait before throwing a timeout error (default: 2.0 seconds)
 *   - pollInterval: Time between condition checks in nanoseconds (default: 50ms)
 *   - description: Description of what we're waiting for (used in error messages)
 *   - condition: MainActor-isolated closure that returns a non-nil value when ready
 *
 * - Returns: The value returned by the condition closure when it first returns non-nil
 *
 * - Throws: `TestError.timeout` if the condition doesn't return non-nil within the timeout period
 *
 * - Example:
 * ```swift
 * // Wait for MainActor-isolated state and capture it
 * let state = try await waitForMainActorValue(description: "success state") {
 *     if case let .success(data) = viewModel.viewState {
 *         return data
 *     }
 *     return nil
 * }
 * ```
 */
@MainActor
func waitForMainActorValue<T>(
    timeout: TimeInterval = 2.0,
    pollInterval: UInt64 = 50_000_000, // 50ms
    description: String,
    condition: @escaping @MainActor () -> T?
) async throws -> T {
    let deadline = Date().addingTimeInterval(timeout)

    // Yield to allow pending MainActor work to complete before first check
    await Task.yield()

    while Date() < deadline {
        if let value = condition() {
            return value
        }
        try await Task.sleep(nanoseconds: pollInterval)
    }

    throw TestError.timeout("Timed out waiting for: \(description)")
}
