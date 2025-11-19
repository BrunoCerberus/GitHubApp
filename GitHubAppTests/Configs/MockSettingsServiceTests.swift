//
//  MockSettingsServiceTests.swift
//  GitHubAppTests
//
//  Created by Claude Code to improve test coverage
//

import Combine
import Foundation
@testable import GitHubApp
import Testing
import UIKit

/**
 * Comprehensive unit tests for MockSettingsService.
 *
 * Tests cover:
 * - Profile image operations (load, save, clear)
 * - App rating functionality
 * - Favorite movies clearing
 * - App version info retrieval
 * - Error simulation
 * - Call count tracking
 * - Reset functionality
 */
@MainActor
struct MockSettingsServiceTests {
    // MARK: - Profile Image Tests

    @Test("Load profile image returns nil by default")
    func loadProfileImageReturnsNilByDefault() async throws {
        // Given
        let service = MockSettingsService()
        var cancellables = Set<AnyCancellable>()
        var receivedImage: UIImage?

        // When
        let expectation = expectation()
        service.loadProfileImage()
            .sink { image in
                receivedImage = image
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 1.0)

        // Then
        #expect(receivedImage == nil, "Should return nil by default")
        #expect(service.loadProfileImageCallCount == 1, "Should track call count")
    }

    @Test("Load profile image returns mock image when set")
    func loadProfileImageReturnsMockImageWhenSet() async throws {
        // Given
        let service = MockSettingsService()
        let mockImage = UIImage(systemName: "person.circle")!
        service.mockProfileImage = mockImage
        var cancellables = Set<AnyCancellable>()
        var receivedImage: UIImage?

        // When
        let expectation = expectation()
        service.loadProfileImage()
            .sink { image in
                receivedImage = image
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 1.0)

        // Then
        #expect(receivedImage != nil, "Should return mock image")
        #expect(service.loadProfileImageCallCount == 1, "Should track call count")
    }

    @Test("Save profile image succeeds by default")
    func saveProfileImageSucceedsByDefault() async throws {
        // Given
        let service = MockSettingsService()
        let image = UIImage(systemName: "star")!
        var cancellables = Set<AnyCancellable>()
        var saveSucceeded = false

        // When
        let expectation = expectation()
        service.saveProfileImage(image)
            .sink(
                receiveCompletion: { completion in
                    if case .finished = completion {
                        saveSucceeded = true
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 1.0)

        // Then
        #expect(saveSucceeded, "Should succeed")
        #expect(service.mockProfileImage != nil, "Should save image")
        #expect(service.saveProfileImageCallCount == 1, "Should track call count")
    }

    @Test("Save profile image fails when error simulation enabled")
    func saveProfileImageFailsWhenErrorSimulationEnabled() async throws {
        // Given
        let service = MockSettingsService()
        service.shouldFailSaveProfileImage = true
        let image = UIImage(systemName: "star")!
        var cancellables = Set<AnyCancellable>()
        var receivedError: Error?

        // When
        let expectation = expectation()
        service.saveProfileImage(image)
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        receivedError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 1.0)

        // Then
        #expect(receivedError != nil, "Should receive error")
        #expect(service.saveProfileImageCallCount == 1, "Should track call count")
    }

    @Test("Clear profile image removes image")
    func clearProfileImageRemovesImage() async throws {
        // Given
        let service = MockSettingsService()
        service.mockProfileImage = UIImage(systemName: "person")
        var cancellables = Set<AnyCancellable>()
        var clearSucceeded = false

        // When
        let expectation = expectation()
        service.clearProfileImage()
            .sink { _ in
                clearSucceeded = true
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 1.0)

        // Then
        #expect(clearSucceeded, "Should succeed")
        #expect(service.mockProfileImage == nil, "Should clear image")
        #expect(service.clearProfileImageCallCount == 1, "Should track call count")
    }

    // MARK: - App Rating Tests

    @Test("Has rated app returns false by default")
    func hasRatedAppReturnsFalseByDefault() async throws {
        // Given
        let service = MockSettingsService()
        var cancellables = Set<AnyCancellable>()
        var hasRated = true

        // When
        let expectation = expectation()
        service.hasRatedApp()
            .sink { rated in
                hasRated = rated
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 1.0)

        // Then
        #expect(!hasRated, "Should return false by default")
        #expect(service.hasRatedAppCallCount == 1, "Should track call count")
    }

    @Test("Has rated app returns mock value when set")
    func hasRatedAppReturnsMockValueWhenSet() async throws {
        // Given
        let service = MockSettingsService()
        service.mockHasRatedApp = true
        var cancellables = Set<AnyCancellable>()
        var hasRated = false

        // When
        let expectation = expectation()
        service.hasRatedApp()
            .sink { rated in
                hasRated = rated
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 1.0)

        // Then
        #expect(hasRated, "Should return mock value")
        #expect(service.hasRatedAppCallCount == 1, "Should track call count")
    }

    @Test("Mark app as rated sets flag to true")
    func markAppAsRatedSetsFlagToTrue() async throws {
        // Given
        let service = MockSettingsService()
        var cancellables = Set<AnyCancellable>()
        var markSucceeded = false

        // When
        let expectation = expectation()
        service.markAppAsRated()
            .sink { _ in
                markSucceeded = true
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 1.0)

        // Then
        #expect(markSucceeded, "Should succeed")
        #expect(service.mockHasRatedApp, "Should set flag to true")
        #expect(service.markAppAsRatedCallCount == 1, "Should track call count")
    }

    // MARK: - Clear Favorites Tests

    @Test("Clear all favorite movies succeeds by default")
    func clearAllFavoriteMoviesSucceedsByDefault() async throws {
        // Given
        let service = MockSettingsService()
        var cancellables = Set<AnyCancellable>()
        var clearSucceeded = false

        // When
        let expectation = expectation()
        service.clearAllFavoriteMovies()
            .sink(
                receiveCompletion: { completion in
                    if case .finished = completion {
                        clearSucceeded = true
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 1.0)

        // Then
        #expect(clearSucceeded, "Should succeed")
        #expect(service.clearAllFavoriteMoviesCallCount == 1, "Should track call count")
    }

    @Test("Clear all favorite movies fails when error simulation enabled")
    func clearAllFavoriteMoviesFailsWhenErrorSimulationEnabled() async throws {
        // Given
        let service = MockSettingsService()
        service.shouldFailClearFavoriteMovies = true
        var cancellables = Set<AnyCancellable>()
        var receivedError: Error?

        // When
        let expectation = expectation()
        service.clearAllFavoriteMovies()
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        receivedError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 1.0)

        // Then
        #expect(receivedError != nil, "Should receive error")
        #expect(service.clearAllFavoriteMoviesCallCount == 1, "Should track call count")
    }

    // MARK: - App Version Info Tests

    @Test("Get app version info returns default values")
    func getAppVersionInfoReturnsDefaultValues() async throws {
        // Given
        let service = MockSettingsService()
        var cancellables = Set<AnyCancellable>()
        var receivedVersion: String?
        var receivedBuildNumber: String?

        // When
        let expectation = expectation()
        service.getAppVersionInfo()
            .sink { versionInfo in
                receivedVersion = versionInfo.version
                receivedBuildNumber = versionInfo.buildNumber
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 1.0)

        // Then
        #expect(receivedVersion == "1.0", "Should return default version")
        #expect(receivedBuildNumber == "1", "Should return default build number")
        #expect(service.getAppVersionInfoCallCount == 1, "Should track call count")
    }

    @Test("Get app version info returns custom values when set")
    func getAppVersionInfoReturnsCustomValuesWhenSet() async throws {
        // Given
        let service = MockSettingsService()
        service.mockAppVersion = "2.5.0"
        service.mockAppBuildNumber = "456"
        var cancellables = Set<AnyCancellable>()
        var receivedVersion: String?
        var receivedBuildNumber: String?

        // When
        let expectation = expectation()
        service.getAppVersionInfo()
            .sink { versionInfo in
                receivedVersion = versionInfo.version
                receivedBuildNumber = versionInfo.buildNumber
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 1.0)

        // Then
        #expect(receivedVersion == "2.5.0", "Should return custom version")
        #expect(receivedBuildNumber == "456", "Should return custom build number")
        #expect(service.getAppVersionInfoCallCount == 1, "Should track call count")
    }

    // MARK: - Reset Tests

    @Test("Reset clears all mock state")
    func resetClearsAllMockState() {
        // Given
        let service = MockSettingsService()
        service.mockProfileImage = UIImage(systemName: "person")
        service.mockHasRatedApp = true
        service.mockAppVersion = "5.0"
        service.mockAppBuildNumber = "999"
        service.shouldFailSaveProfileImage = true
        service.shouldFailClearFavoriteMovies = true
        service.loadProfileImageCallCount = 10
        service.saveProfileImageCallCount = 10
        service.clearProfileImageCallCount = 10
        service.hasRatedAppCallCount = 10
        service.markAppAsRatedCallCount = 10
        service.clearAllFavoriteMoviesCallCount = 10
        service.getAppVersionInfoCallCount = 10

        // When
        service.reset()

        // Then
        #expect(service.mockProfileImage == nil, "Should clear profile image")
        #expect(!service.mockHasRatedApp, "Should reset has rated flag")
        #expect(service.mockAppVersion == "1.0.0", "Should reset app version")
        #expect(service.mockAppBuildNumber == "123", "Should reset build number")
        #expect(!service.shouldFailSaveProfileImage, "Should reset save image error flag")
        #expect(!service.shouldFailClearFavoriteMovies, "Should reset clear favorites error flag")
        #expect(service.loadProfileImageCallCount == 0, "Should reset call count")
        #expect(service.saveProfileImageCallCount == 0, "Should reset call count")
        #expect(service.clearProfileImageCallCount == 0, "Should reset call count")
        #expect(service.hasRatedAppCallCount == 0, "Should reset call count")
        #expect(service.markAppAsRatedCallCount == 0, "Should reset call count")
        #expect(service.clearAllFavoriteMoviesCallCount == 0, "Should reset call count")
        #expect(service.getAppVersionInfoCallCount == 0, "Should reset call count")
    }

    // MARK: - Multiple Call Tests

    @Test("Multiple calls increment call counts correctly")
    func multipleCallsIncrementCallCountsCorrectly() async throws {
        // Given
        let service = MockSettingsService()
        var cancellables = Set<AnyCancellable>()

        // When
        let expectation = expectation()
        expectation.expectedFulfillmentCount = 6

        service.loadProfileImage()
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)

        service.loadProfileImage()
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)

        service.hasRatedApp()
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)

        service.markAppAsRated()
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)

        service.getAppVersionInfo()
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)

        service.getAppVersionInfo()
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 2.0)

        // Then
        #expect(service.loadProfileImageCallCount == 2, "Should track multiple calls")
        #expect(service.hasRatedAppCallCount == 1, "Should track calls")
        #expect(service.markAppAsRatedCallCount == 1, "Should track calls")
        #expect(service.getAppVersionInfoCallCount == 2, "Should track multiple calls")
    }
}

/**
 * Helper for async testing expectations.
 */
private func expectation() -> TestExpectation {
    TestExpectation()
}

private final class TestExpectation: @unchecked Sendable {
    private var fulfilled = false
    private var fulfillmentCount = 0
    var expectedFulfillmentCount = 1

    func fulfill() {
        fulfillmentCount += 1
        if fulfillmentCount >= expectedFulfillmentCount {
            fulfilled = true
        }
    }

    func waitForFulfillment(timeout: TimeInterval) async {
        let deadline = Date().addingTimeInterval(timeout)
        while !fulfilled, Date() < deadline {
            try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
        }
    }
}
