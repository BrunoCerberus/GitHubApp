//
//  SettingsViewModelTests.swift
//  GitHubAppTests
//
//  Created by bruno on settings functionality.
//

import Combine
import UIKit
import XCTest

@testable import GitHubApp

/**
 * Unit tests for SettingsViewModel functionality following Clean Architecture.
 */
@MainActor
final class SettingsViewModelTests: XCTestCase {
    var mockSettingsService: MockSettingsService!
    var mockDomainInteractor: SettingsDomainInteractor!
    var mockViewStateReducer: SettingsViewStateReducer!
    var settingsViewModel: SettingsViewModel!
    var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        mockSettingsService = MockSettingsService()
        mockDomainInteractor = SettingsDomainInteractor(
            settingsService: mockSettingsService,
            shouldLoadInitialData: false
        )
        mockViewStateReducer = SettingsViewStateReducer()
        settingsViewModel = SettingsViewModel(
            service: mockSettingsService,
            domainInteractor: mockDomainInteractor,
            viewStateReducer: mockViewStateReducer
        )
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        cancellables.removeAll()
        mockSettingsService = nil
        mockDomainInteractor = nil
        mockViewStateReducer = nil
        settingsViewModel = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        // Given - Setup in setUp()

        // Then
        XCTAssertEqual(settingsViewModel.viewState, .loading)
        XCTAssertEqual(settingsViewModel.appVersion, "1.0") // Default before data loads
        XCTAssertEqual(settingsViewModel.appBuildNumber, "1") // Default before data loads
        XCTAssertFalse(settingsViewModel.isPhotoPickerPresented)
        XCTAssertFalse(settingsViewModel.isClearLikedMoviesConfirmationPresented)
        XCTAssertFalse(settingsViewModel.showClearLikedMoviesAlert)
        XCTAssertFalse(settingsViewModel.showRateAppThanks)
    }

    // MARK: - View State Tests

    func testViewStateLoadingToSuccess() {
        let expectation = XCTestExpectation(description: "View state updates to success")

        // Given - Create a fresh mock service with updated values
        let freshMockService = MockSettingsService()

        // Create fresh domain interactor with updated mock
        let freshDomainInteractor = SettingsDomainInteractor(
            settingsService: freshMockService,
            shouldLoadInitialData: false
        )

        let freshViewModel = SettingsViewModel(
            service: freshMockService,
            domainInteractor: freshDomainInteractor,
            viewStateReducer: mockViewStateReducer
        )

        // When - Wait for initial automatic load and then check result
        freshViewModel.$viewState
            .sink { state in
                switch state {
                case let .success(dataViewState):
                    // Then
                    XCTAssertEqual(dataViewState.appVersion, "1.0")
                    XCTAssertEqual(dataViewState.appBuildNumber, "1")
                    XCTAssertFalse(dataViewState.hasRatedApp)
                    XCTAssertNil(dataViewState.profileImage)
                    expectation.fulfill()
                case .loading:
                    // Expected initial state
                    break
                case .error:
                    XCTFail("Unexpected error state")
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Profile Image Tests

    func testProfileImageSelection() {
        let expectation = XCTestExpectation(description: "Profile image saved")

        // Given
        let testImage = UIImage(systemName: "person.fill")!

        // When
        settingsViewModel.$viewState
            .dropFirst() // Skip loading state
            .sink { state in
                if case let .success(dataViewState) = state,
                   dataViewState.profileImage != nil
                {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        settingsViewModel.handleProfileImageSelection(testImage)

        wait(for: [expectation], timeout: 2.0)

        // Then
        XCTAssertEqual(mockSettingsService.saveProfileImageCallCount, 1)
        XCTAssertNotNil(mockSettingsService.mockProfileImage)
    }

    func testClearProfileImage() {
        let expectation = XCTestExpectation(description: "Profile image cleared")

        // Given
        let testImage = UIImage(systemName: "person.fill")!
        mockSettingsService.mockProfileImage = testImage

        // When
        settingsViewModel.$viewState
            .dropFirst() // Skip loading state
            .sink { state in
                if case let .success(dataViewState) = state,
                   dataViewState.profileImage == nil
                {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        settingsViewModel.clearProfileImage()

        wait(for: [expectation], timeout: 2.0)

        // Then
        XCTAssertEqual(mockSettingsService.clearProfileImageCallCount, 1)
        XCTAssertNil(mockSettingsService.mockProfileImage)
    }

    // MARK: - App Rating Tests

    func testRateApp() {
        let expectation = XCTestExpectation(description: "App rated")

        // Given
        XCTAssertFalse(mockSettingsService.mockHasRatedApp)

        // When
        settingsViewModel.$viewState
            .dropFirst() // Skip loading state
            .sink { state in
                if case let .success(dataViewState) = state,
                   dataViewState.hasRatedApp, dataViewState.showRateAppThanks
                {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        settingsViewModel.rateApp()

        wait(for: [expectation], timeout: 2.0)

        // Then
        XCTAssertEqual(mockSettingsService.markAppAsRatedCallCount, 1)
        XCTAssertTrue(mockSettingsService.mockHasRatedApp)
    }

    // MARK: - Clear Favorite Movies Tests

    func testClearAllFavoriteMovies() {
        let expectation = XCTestExpectation(description: "Favorite movies cleared")

        // When
        settingsViewModel.$viewState
            .dropFirst() // Skip loading state
            .sink { state in
                if case let .success(dataViewState) = state,
                   dataViewState.showClearFavoriteMoviesAlert
                {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        settingsViewModel.clearAllFavoriteMovies()

        wait(for: [expectation], timeout: 2.0)

        // Then
        XCTAssertEqual(mockSettingsService.clearAllFavoriteMoviesCallCount, 1)
    }

    // MARK: - Photo Picker Tests

    func testShowPhotoPicker() {
        let expectation = XCTestExpectation(description: "Photo picker shown")

        // When
        settingsViewModel.$viewState
            .dropFirst() // Skip loading state
            .sink { state in
                if case let .success(dataViewState) = state,
                   dataViewState.isPhotoPickerPresented
                {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        settingsViewModel.showPhotoPicker()

        wait(for: [expectation], timeout: 2.0)
    }

    func testHidePhotoPicker() {
        let expectation = XCTestExpectation(description: "Photo picker hidden")

        // Given - First show the picker
        settingsViewModel.showPhotoPicker()

        // When
        let viewModel = settingsViewModel! // Capture strong reference
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            viewModel.hidePhotoPicker()
        }

        settingsViewModel.$viewState
            .dropFirst() // Skip loading state
            .sink { state in
                if case let .success(dataViewState) = state,
                   !dataViewState.isPhotoPickerPresented
                {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Clear Favorite Movies Confirmation Tests

    func testShowClearLikedMoviesConfirmation() {
        let expectation = XCTestExpectation(description: "Confirmation shown")

        // When
        settingsViewModel.$viewState
            .dropFirst() // Skip loading state
            .sink { state in
                if case let .success(dataViewState) = state,
                   dataViewState.isClearFavoriteMoviesConfirmationPresented
                {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        settingsViewModel.showClearLikedMoviesConfirmation()

        wait(for: [expectation], timeout: 2.0)
    }

    func testHideClearLikedMoviesConfirmation() {
        let expectation = XCTestExpectation(description: "Confirmation hidden")

        // Given - First show the confirmation
        settingsViewModel.showClearLikedMoviesConfirmation()

        // When
        let viewModel = settingsViewModel! // Capture strong reference
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            viewModel.hideClearLikedMoviesConfirmation()
        }

        settingsViewModel.$viewState
            .dropFirst() // Skip loading state
            .sink { state in
                if case let .success(dataViewState) = state,
                   !dataViewState.isClearFavoriteMoviesConfirmationPresented
                {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Error Handling Tests

    func testErrorStateForProfileImageSave() {
        let expectation = XCTestExpectation(description: "Error state on save failure")

        // Given
        mockSettingsService.shouldFailSaveProfileImage = true
        let testImage = UIImage(systemName: "person.fill")!

        // When
        settingsViewModel.$viewState
            .sink { [weak self] state in
                guard self != nil else { return }
                if case let .error(message) = state {
                    XCTAssertFalse(message.isEmpty)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        settingsViewModel.handleProfileImageSelection(testImage)

        wait(for: [expectation], timeout: 2.0)
    }

    func testErrorStateForClearFavoriteMovies() {
        let expectation = XCTestExpectation(description: "Error state on clear failure")

        // Given
        mockSettingsService.shouldFailClearFavoriteMovies = true

        // When
        settingsViewModel.$viewState
            .sink { [weak self] state in
                guard self != nil else { return }
                if case let .error(message) = state {
                    XCTAssertFalse(message.isEmpty)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        settingsViewModel.clearAllFavoriteMovies()

        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Computed Properties Tests

    func testComputedPropertiesInLoadingState() {
        // Given - Initial loading state

        // Then
        XCTAssertEqual(settingsViewModel.appVersion, "1.0")
        XCTAssertEqual(settingsViewModel.appBuildNumber, "1")
        XCTAssertNil(settingsViewModel.profileImage)
        XCTAssertFalse(settingsViewModel.hasRatedApp)
        XCTAssertNil(settingsViewModel.error)
    }

    func testComputedPropertiesInErrorState() {
        let expectation = XCTestExpectation(description: "Error state computed properties")

        // Given
        let testImage = UIImage(systemName: "person.fill")!

        // Use the existing view model but set it up to fail
        mockSettingsService.shouldFailSaveProfileImage = true

        // When
        settingsViewModel.$viewState
            .sink { [weak self] state in
                if case let .error(message) = state {
                    // Then - Test the computed property within the same execution context
                    DispatchQueue.main.async {
                        guard let self else { return }
                        XCTAssertNotNil(self.settingsViewModel.error)
                        XCTAssertFalse(self.settingsViewModel.error?.isEmpty ?? true)
                        XCTAssertEqual(self.settingsViewModel.error, message)
                        expectation.fulfill()
                    }
                }
            }
            .store(in: &cancellables)

        // Trigger the error
        settingsViewModel.handleProfileImageSelection(testImage)

        wait(for: [expectation], timeout: 3.0)
    }
}
