//
//  SettingsDomainInteractorTests.swift
//  GitHubAppTests
//
//  Created by bruno on feature/settings-clean-architecture.
//

import Combine
import UIKit
import XCTest

@testable import GitHubApp

/**
 * Unit tests for SettingsDomainInteractor.
 */
@MainActor
final class SettingsDomainInteractorTests: XCTestCase {
    var mockSettingsService: MockSettingsService!
    var domainInteractor: SettingsDomainInteractor!
    var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        mockSettingsService = MockSettingsService()
        // Initialize with a clean initial state and prevent auto-loading
        domainInteractor = SettingsDomainInteractor(
            settingsService: mockSettingsService,
            initialState: SettingsDomainState.initial,
            shouldLoadInitialData: false
        )
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        cancellables.removeAll()
        mockSettingsService = nil
        domainInteractor = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        // Then
        XCTAssertEqual(domainInteractor.currentState, SettingsDomainState.initial)
    }

    // MARK: - Load Settings Tests

    func testLoadSettings() {
        let expectation = XCTestExpectation(description: "Settings loaded")

        // Given
        mockSettingsService.mockAppVersion = "2.0.0"
        mockSettingsService.mockAppBuildNumber = "456"
        mockSettingsService.mockHasRatedApp = true

        // When
        domainInteractor.$currentState
            .dropFirst() // Skip initial state
            .sink { state in
                if !state.isLoading, state.error == nil {
                    // Then
                    XCTAssertEqual(state.appVersion, "2.0.0")
                    XCTAssertEqual(state.appBuildNumber, "456")
                    XCTAssertTrue(state.hasRatedApp)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        domainInteractor.handleAction(.loadSettings)

        wait(for: [expectation], timeout: 2.0)

        // Verify service calls
        XCTAssertEqual(mockSettingsService.loadProfileImageCallCount, 1)
        XCTAssertEqual(mockSettingsService.hasRatedAppCallCount, 1)
        XCTAssertEqual(mockSettingsService.getAppVersionInfoCallCount, 1)
    }

    // MARK: - Profile Image Tests

    func testSaveProfileImage() {
        let expectation = XCTestExpectation(description: "Profile image saved")

        // Given
        let testImage = UIImage(systemName: "person.fill")!

        // When
        domainInteractor.$currentState
            .dropFirst() // Skip initial state
            .sink { state in
                if state.profileImage != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        domainInteractor.handleAction(.saveProfileImage(testImage))

        wait(for: [expectation], timeout: 2.0)

        // Then
        XCTAssertEqual(mockSettingsService.saveProfileImageCallCount, 1)
        XCTAssertNotNil(mockSettingsService.mockProfileImage)
    }

    func testClearProfileImage() {
        // Given
        let testImage = UIImage(systemName: "person.fill")!
        let originalState = SettingsDomainState.initial.withProfileImage(testImage)

        // Test the new withProfileImage method
        XCTAssertNotNil(originalState.profileImage)
        let clearedState = originalState.withProfileImage(nil)
        XCTAssertNil(clearedState.profileImage, "withProfileImage(nil) should clear profile image")

        // Set up interactor state
        domainInteractor.currentState = originalState
        XCTAssertNotNil(domainInteractor.currentState.profileImage)

        // When
        domainInteractor.handleAction(.clearProfileImage)

        // Then - Check synchronously after a short delay to allow Combine chain to complete
        let expectation = XCTestExpectation(description: "Profile image cleared")
        let mockService = mockSettingsService! // Capture strong reference
        let interactor = domainInteractor! // Capture strong reference
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(mockService.clearProfileImageCallCount, 1)
            XCTAssertNil(interactor.currentState.profileImage)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - App Rating Tests

    func testRateApp() {
        let expectation = XCTestExpectation(description: "App rated")

        // Given
        XCTAssertFalse(domainInteractor.currentState.hasRatedApp)

        // When
        domainInteractor.$currentState
            .dropFirst() // Skip initial state
            .sink { state in
                if state.hasRatedApp, state.showRateAppThanks {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        domainInteractor.handleAction(.rateApp)

        wait(for: [expectation], timeout: 3.0) // Longer timeout for auto-hide delay

        // Then
        XCTAssertEqual(mockSettingsService.markAppAsRatedCallCount, 1)
    }

    // MARK: - Clear Favorite Movies Tests

    func testClearAllFavoriteMovies() {
        let expectation = XCTestExpectation(description: "Favorite movies cleared")

        // When
        domainInteractor.$currentState
            .dropFirst() // Skip initial state
            .sink { state in
                if state.showClearFavoriteMoviesAlert {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        domainInteractor.handleAction(.clearAllFavoriteMovies)

        wait(for: [expectation], timeout: 2.0)

        // Then
        XCTAssertEqual(mockSettingsService.clearAllFavoriteMoviesCallCount, 1)
    }

    // MARK: - UI State Tests

    func testShowPhotoPicker() {
        // When
        domainInteractor.handleAction(.showPhotoPicker)

        // Then
        XCTAssertTrue(domainInteractor.currentState.isPhotoPickerPresented)
    }

    func testHidePhotoPicker() {
        // Given
        domainInteractor.handleAction(.showPhotoPicker)
        XCTAssertTrue(domainInteractor.currentState.isPhotoPickerPresented)

        // When
        domainInteractor.handleAction(.hidePhotoPicker)

        // Then
        XCTAssertFalse(domainInteractor.currentState.isPhotoPickerPresented)
    }

    func testShowClearFavoriteMoviesConfirmation() {
        // When
        domainInteractor.handleAction(.showClearFavoriteMoviesConfirmation)

        // Then
        XCTAssertTrue(domainInteractor.currentState.isClearFavoriteMoviesConfirmationPresented)
    }

    func testHideClearFavoriteMoviesConfirmation() {
        // Given
        domainInteractor.handleAction(.showClearFavoriteMoviesConfirmation)
        XCTAssertTrue(domainInteractor.currentState.isClearFavoriteMoviesConfirmationPresented)

        // When
        domainInteractor.handleAction(.hideClearFavoriteMoviesConfirmation)

        // Then
        XCTAssertFalse(domainInteractor.currentState.isClearFavoriteMoviesConfirmationPresented)
    }

    // MARK: - Error Handling Tests

    func testSaveProfileImageError() {
        let expectation = XCTestExpectation(description: "Save profile image error handled")

        // Given
        mockSettingsService.shouldFailSaveProfileImage = true
        let testImage = UIImage(systemName: "person.fill")!

        // When
        domainInteractor.$currentState
            .dropFirst() // Skip initial state
            .sink { state in
                if let error = state.error, !error.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        domainInteractor.handleAction(.saveProfileImage(testImage))

        wait(for: [expectation], timeout: 2.0)
    }

    func testClearFavoriteMoviesError() {
        let expectation = XCTestExpectation(description: "Clear favorite movies error handled")

        // Given
        mockSettingsService.shouldFailClearFavoriteMovies = true

        // When
        domainInteractor.$currentState
            .dropFirst() // Skip initial state
            .sink { state in
                if let error = state.error, !error.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        domainInteractor.handleAction(.clearAllFavoriteMovies)

        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - CombineInteractor Protocol Tests

    func testInteractWithUpstream() {
        // Given
        let actions = [SettingsDomainAction.showPhotoPicker, SettingsDomainAction.hidePhotoPicker]
        let publisher = actions.publisher.eraseToAnyPublisher()

        // When
        let statePublisher = domainInteractor.interact(upstream: publisher)

        // Set up subscription
        statePublisher.sink { _ in }.store(in: &cancellables)

        // Wait for actions to process
        let expectation = expectation(description: "Actions processed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)

        // Then
        XCTAssertFalse(domainInteractor.currentState.isPhotoPickerPresented)
    }
}
