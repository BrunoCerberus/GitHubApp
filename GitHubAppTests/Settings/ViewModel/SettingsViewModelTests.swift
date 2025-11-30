// swiftlint:disable file_length
//
//  SettingsViewModelTests.swift
//  GitHubAppTests
//
//  Created by bruno on settings functionality.
//

import Combine
@testable import GitHubApp
import Testing
import UIKit

@MainActor
struct SettingsViewModelTests { // swiftlint:disable:this type_body_length
    private func createTestComponents() -> (SettingsViewModel, MockSettingsService) {
        let mockSettingsService = MockSettingsService()
        let mockStorageService = MockStorageService()
        let serviceLocator = ServiceLocator()
        serviceLocator.register(SettingsService.self, instance: mockSettingsService)
        serviceLocator.register(StorageService.self, instance: mockStorageService)

        let mockDomainInteractor = SettingsDomainInteractor(
            serviceLocator: serviceLocator,
            shouldLoadInitialData: false
        )
        let mockViewStateReducer = SettingsViewStateReducer()
        let settingsViewModel = SettingsViewModel(
            serviceLocator: serviceLocator,
            domainInteractor: mockDomainInteractor,
            viewStateReducer: mockViewStateReducer
        )

        return (settingsViewModel, mockSettingsService)
    }

    // MARK: - Initialization Tests

    @Test("Initial state shows loading with default values")
    func initialization() async {
        // Given
        let (settingsViewModel, _) = createTestComponents()

        // Then - Check initial values (state may load quickly in test environment)
        await MainActor.run {
            // State may be loading or success depending on timing in test environment
            if case .loading = settingsViewModel.viewState {
                // Expected loading state
            } else if case let .success(dataState) = settingsViewModel.viewState {
                // Fast loading in test environment is also acceptable
                #expect(dataState.appVersion == "1.0")
                #expect(dataState.appBuildNumber == "1")
                #expect(!dataState.hasRatedApp)
            }
            #expect(settingsViewModel.appVersion == "1.0") // Default before data loads
            #expect(settingsViewModel.appBuildNumber == "1") // Default before data loads
            #expect(!settingsViewModel.isPhotoPickerPresented)
            #expect(!settingsViewModel.isClearLikedMoviesConfirmationPresented)
            #expect(!settingsViewModel.showClearLikedMoviesAlert)
            #expect(!settingsViewModel.showRateAppThanks)
        }
    }

    // MARK: - View State Tests

    @Test("View state transitions from loading to success")
    func viewStateLoadingToSuccess() async throws {
        // Given - Create a fresh mock service with updated values
        let freshMockService = MockSettingsService()
        let freshServiceLocator = ServiceLocator()
        freshServiceLocator.register(SettingsService.self, instance: freshMockService)

        let freshDomainInteractor = SettingsDomainInteractor(
            serviceLocator: freshServiceLocator,
            shouldLoadInitialData: false
        )
        let mockViewStateReducer = SettingsViewStateReducer()
        let freshViewModel = SettingsViewModel(
            serviceLocator: freshServiceLocator,
            domainInteractor: freshDomainInteractor,
            viewStateReducer: mockViewStateReducer
        )

        // When - Wait for view state updates
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        await MainActor.run {
            // Then
            if case let .success(dataViewState) = freshViewModel.viewState {
                #expect(dataViewState.appVersion == "1.0")
                #expect(dataViewState.appBuildNumber == "1")
                #expect(!dataViewState.hasRatedApp)
                #expect(dataViewState.profileImage == nil)
            }
        }
    }

    // MARK: - Profile Image Tests

    @Test("Profile image selection saves image successfully")
    func profileImageSelection() async throws {
        // Given
        let (settingsViewModel, mockSettingsService) = createTestComponents()
        let testImage = UIImage(systemName: "person.fill")!

        // When
        await MainActor.run {
            settingsViewModel.handleProfileImageSelection(testImage)
        }

        // Wait for async operation
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then
        await MainActor.run {
            #expect(mockSettingsService.saveProfileImageCallCount == 1)
            #expect(mockSettingsService.mockProfileImage != nil)

            if case let .success(dataViewState) = settingsViewModel.viewState {
                #expect(dataViewState.profileImage != nil)
            }
        }
    }

    @Test("Clear profile image removes stored image")
    func clearProfileImage() async throws {
        // Given
        let (settingsViewModel, mockSettingsService) = createTestComponents()
        let testImage = UIImage(systemName: "person.fill")!
        mockSettingsService.mockProfileImage = testImage

        // When
        await MainActor.run {
            settingsViewModel.clearProfileImage()
        }

        // Wait for async operation
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then
        await MainActor.run {
            #expect(mockSettingsService.clearProfileImageCallCount == 1)
            #expect(mockSettingsService.mockProfileImage == nil)

            if case let .success(dataViewState) = settingsViewModel.viewState {
                #expect(dataViewState.profileImage == nil)
            }
        }
    }

    // MARK: - App Rating Tests

    @Test("Rate app marks app as rated and shows thanks")
    func rateApp() async throws {
        // Given
        let (settingsViewModel, mockSettingsService) = createTestComponents()
        #expect(!mockSettingsService.mockHasRatedApp)

        // When
        await MainActor.run {
            settingsViewModel.rateApp()
        }

        // Wait for app to be marked as rated
        // Increased timeout from 2.0 to 5.0 for reliability when IS_RUNNING_UNIT_TESTS is set
        try await waitForMainActorCondition(timeout: 5.0, description: "app marked as rated") {
            mockSettingsService.markAppAsRatedCallCount == 1 &&
                mockSettingsService.mockHasRatedApp
        }

        // Then verify app was marked as rated in viewState
        // Note: showRateAppThanks auto-hides after 2 seconds, so we don't test it here
        await MainActor.run {
            #expect(mockSettingsService.markAppAsRatedCallCount == 1)
            #expect(mockSettingsService.mockHasRatedApp)

            if case let .success(dataViewState) = settingsViewModel.viewState {
                #expect(dataViewState.hasRatedApp)
            }
        }
    }

    // MARK: - Clear Favorite Movies Tests

    @Test("Clear all favorite movies shows confirmation alert")
    func clearAllFavoriteMovies() async throws {
        // Given
        let (settingsViewModel, _) = createTestComponents()

        // When
        await MainActor.run {
            settingsViewModel.clearAllFavoriteMovies()
        }

        // Wait for async operation to complete and alert to be shown
        try await waitForMainActorCondition(timeout: 3.0, description: "clear favorites alert shown") {
            if case let .success(dataViewState) = settingsViewModel.viewState {
                return dataViewState.showClearFavoriteMoviesAlert
            }
            return false
        }

        // Then
        await MainActor.run {
            // The domain interactor now calls StorageService directly
            if case let .success(dataViewState) = settingsViewModel.viewState {
                #expect(dataViewState.showClearFavoriteMoviesAlert)
            }
        }
    }

    // MARK: - Photo Picker Tests

    @Test("Show photo picker updates presentation state")
    func showPhotoPicker() async throws {
        // Given
        let (settingsViewModel, _) = createTestComponents()

        // When
        await MainActor.run {
            settingsViewModel.showPhotoPicker()
        }

        // Wait for async operation
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then
        await MainActor.run {
            if case let .success(dataViewState) = settingsViewModel.viewState {
                #expect(dataViewState.isPhotoPickerPresented)
            }
        }
    }

    @Test("Hide photo picker updates presentation state")
    func hidePhotoPicker() async throws {
        // Given
        let (settingsViewModel, _) = createTestComponents()

        await MainActor.run {
            settingsViewModel.showPhotoPicker()
        }
        try await Task.sleep(nanoseconds: 100_000_000) // Wait for show operation

        // When
        await MainActor.run {
            settingsViewModel.hidePhotoPicker()
        }

        // Wait for async operation
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then
        await MainActor.run {
            if case let .success(dataViewState) = settingsViewModel.viewState {
                #expect(!dataViewState.isPhotoPickerPresented)
            }
        }
    }

    // MARK: - Clear Favorite Movies Confirmation Tests

    @Test("Show clear liked movies confirmation updates state")
    func showClearLikedMoviesConfirmation() async throws {
        // Given
        let (settingsViewModel, _) = createTestComponents()

        // When
        await MainActor.run {
            settingsViewModel.showClearLikedMoviesConfirmation()
        }

        // Wait for async operation
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then
        await MainActor.run {
            if case let .success(dataViewState) = settingsViewModel.viewState {
                #expect(dataViewState.showClearFavoritesConfirm)
            }
        }
    }

    @Test("Hide clear liked movies confirmation updates state")
    func hideClearLikedMoviesConfirmation() async throws {
        // Given
        let (settingsViewModel, _) = createTestComponents()

        await MainActor.run {
            settingsViewModel.showClearLikedMoviesConfirmation()
        }
        try await Task.sleep(nanoseconds: 100_000_000) // Wait for show operation

        // When
        await MainActor.run {
            settingsViewModel.hideClearLikedMoviesConfirmation()
        }

        // Wait for async operation
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then
        await MainActor.run {
            if case let .success(dataViewState) = settingsViewModel.viewState {
                #expect(!dataViewState.showClearFavoritesConfirm)
            }
        }
    }

    // MARK: - Error Handling Tests

    @Test("Error state for profile image save failure")
    func errorStateForProfileImageSave() async throws {
        // Given
        let (settingsViewModel, mockSettingsService) = createTestComponents()
        mockSettingsService.shouldFailSaveProfileImage = true
        let testImage = UIImage(systemName: "person.fill")!

        // When
        await MainActor.run {
            settingsViewModel.handleProfileImageSelection(testImage)
        }

        // Wait for async operation
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then
        await MainActor.run {
            if case let .error(message) = settingsViewModel.viewState {
                #expect(!message.isEmpty)
            }
        }
    }

    @Test("Error state for clear favorite movies failure")
    func errorStateForClearFavoriteMovies() async throws {
        // Given - Create components with a failing StorageService
        let mockSettingsService = MockSettingsService()
        let mockStorageService = MockStorageService()
        mockStorageService.shouldSimulateErrors = true
        let userInfo = [NSLocalizedDescriptionKey: "Failed to clear favorites"]
        mockStorageService.clearError = NSError(domain: "TestError", code: 1, userInfo: userInfo)

        let serviceLocator = ServiceLocator()
        serviceLocator.register(SettingsService.self, instance: mockSettingsService)
        serviceLocator.register(StorageService.self, instance: mockStorageService)

        let mockDomainInteractor = SettingsDomainInteractor(
            serviceLocator: serviceLocator,
            shouldLoadInitialData: false
        )
        let mockViewStateReducer = SettingsViewStateReducer()
        let settingsViewModel = SettingsViewModel(
            serviceLocator: serviceLocator,
            domainInteractor: mockDomainInteractor,
            viewStateReducer: mockViewStateReducer
        )

        // When
        await MainActor.run {
            settingsViewModel.clearAllFavoriteMovies()
        }

        // Wait for error state (longer timeout for async Task + error propagation through Combine pipeline)
        try await waitForMainActorCondition(timeout: 10.0, description: "error state") {
            if case .error = settingsViewModel.viewState {
                return true
            }
            return false
        }

        // Then
        await MainActor.run {
            if case let .error(message) = settingsViewModel.viewState {
                #expect(!message.isEmpty)
            }
        }
    }

    // MARK: - Computed Properties Tests

    @Test("Computed properties in loading state return defaults")
    func computedPropertiesInLoadingState() async {
        // Given
        let (settingsViewModel, _) = createTestComponents()

        // Then
        await MainActor.run {
            #expect(settingsViewModel.appVersion == "1.0")
            #expect(settingsViewModel.appBuildNumber == "1")
            #expect(settingsViewModel.profileImage == nil)
            #expect(!settingsViewModel.hasRatedApp)
            #expect(settingsViewModel.error == nil)
        }
    }

    @Test("Computed properties in error state return error message")
    func computedPropertiesInErrorState() async throws {
        // Given
        let (settingsViewModel, mockSettingsService) = createTestComponents()
        let testImage = UIImage(systemName: "person.fill")!
        mockSettingsService.shouldFailSaveProfileImage = true

        // When - Trigger the error
        await MainActor.run {
            settingsViewModel.handleProfileImageSelection(testImage)
        }

        // Wait for async operation
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then
        await MainActor.run {
            #expect(settingsViewModel.error != nil)
            #expect(!(settingsViewModel.error?.isEmpty ?? true))

            if case let .error(message) = settingsViewModel.viewState {
                #expect(settingsViewModel.error == message)
            }
        }
    }
}
