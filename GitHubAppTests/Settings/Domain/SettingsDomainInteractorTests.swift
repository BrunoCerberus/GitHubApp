//
//  SettingsDomainInteractorTests.swift
//  GitHubAppTests
//
//  Created by bruno on feature/settings-clean-architecture.
//

import Combine
@testable import GitHubApp
import Testing
import UIKit

struct SettingsDomainInteractorTests {
    private func createTestComponents() -> (SettingsDomainInteractor, MockSettingsService) {
        let mockSettingsService = MockSettingsService()
        let mockStorageService = MockStorageService()
        let serviceLocator = ServiceLocator()
        serviceLocator.register(SettingsService.self, instance: mockSettingsService)
        serviceLocator.register(StorageService.self, instance: mockStorageService)

        let domainInteractor = SettingsDomainInteractor(
            serviceLocator: serviceLocator,
            initialState: SettingsDomainState.initial,
            shouldLoadInitialData: false
        )

        return (domainInteractor, mockSettingsService)
    }

    // MARK: - Initialization Tests

    @Test("Initial state is properly configured")
    func initialization() async {
        // Given
        let (domainInteractor, _) = createTestComponents()

        // Then
        await MainActor.run {
            #expect(domainInteractor.currentState == SettingsDomainState.initial)
        }
    }

    // MARK: - Load Settings Tests

    @Test("Load settings updates state with service data")
    func loadSettings() async throws {
        // Given
        let (domainInteractor, mockSettingsService) = createTestComponents()
        mockSettingsService.mockAppVersion = "2.0.0"
        mockSettingsService.mockAppBuildNumber = "456"
        mockSettingsService.mockHasRatedApp = true

        // When
        await MainActor.run {
            domainInteractor.handleAction(.loadSettings)
        }

        // Wait for async operations
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then
        await MainActor.run {
            let state = domainInteractor.currentState
            #expect(!state.isLoading)
            #expect(state.error == nil)
            #expect(state.appVersion == "2.0.0")
            #expect(state.appBuildNumber == "456")
            #expect(state.hasRatedApp)

            // Verify service calls
            #expect(mockSettingsService.loadProfileImageCallCount == 1)
            #expect(mockSettingsService.hasRatedAppCallCount == 1)
            #expect(mockSettingsService.getAppVersionInfoCallCount == 1)
        }
    }

    // MARK: - Profile Image Tests

    @Test("Save profile image updates state and calls service")
    func saveProfileImage() async throws {
        // Given
        let (domainInteractor, mockSettingsService) = createTestComponents()
        let testImage = UIImage(systemName: "person.fill")!

        // When
        await MainActor.run {
            domainInteractor.handleAction(.saveProfileImage(testImage))
        }

        // Wait for async operations
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then
        await MainActor.run {
            #expect(domainInteractor.currentState.profileImage != nil)
            #expect(mockSettingsService.saveProfileImageCallCount == 1)
            #expect(mockSettingsService.mockProfileImage != nil)
        }
    }

    @Test("Clear profile image removes image from state")
    func clearProfileImage() async throws {
        // Given
        let (domainInteractor, mockSettingsService) = createTestComponents()
        let testImage = UIImage(systemName: "person.fill")!
        let originalState = SettingsDomainState.initial.withProfileImage(testImage)

        // Test the new withProfileImage method
        #expect(originalState.profileImage != nil)
        let clearedState = originalState.withProfileImage(nil)
        #expect(clearedState.profileImage == nil)

        // Set up interactor state
        await MainActor.run {
            domainInteractor.currentState = originalState
            #expect(domainInteractor.currentState.profileImage != nil)
        }

        // When
        await MainActor.run {
            domainInteractor.handleAction(.clearProfileImage)
        }

        // Wait for async operations
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Then
        await MainActor.run {
            #expect(mockSettingsService.clearProfileImageCallCount == 1)
            #expect(domainInteractor.currentState.profileImage == nil)
        }
    }

    // MARK: - App Rating Tests

    @Test("Rate app marks app as rated and shows thanks")
    func rateApp() async throws {
        // Given
        let (domainInteractor, mockSettingsService) = createTestComponents()

        await MainActor.run {
            #expect(!domainInteractor.currentState.hasRatedApp)
        }

        // When
        await MainActor.run {
            domainInteractor.handleAction(.rateApp)
        }

        // Wait for async operations (longer timeout for auto-hide delay)
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        // Then
        await MainActor.run {
            let state = domainInteractor.currentState
            #expect(state.hasRatedApp)
            #expect(state.showRateAppThanks)
            #expect(mockSettingsService.markAppAsRatedCallCount == 1)
        }
    }

    // MARK: - Clear Favorite Movies Tests

    @Test("Clear all favorite movies shows alert and calls service")
    func clearAllFavoriteMovies() async throws {
        // Given
        let mockSettingsService = MockSettingsService()
        let mockStorageService = MockStorageService()
        let serviceLocator = ServiceLocator()
        serviceLocator.register(SettingsService.self, instance: mockSettingsService)
        serviceLocator.register(StorageService.self, instance: mockStorageService)

        let domainInteractor = SettingsDomainInteractor(
            serviceLocator: serviceLocator,
            initialState: SettingsDomainState.initial,
            shouldLoadInitialData: false
        )

        // When
        await MainActor.run {
            domainInteractor.handleAction(.clearAllFavoriteMovies)
        }

        // Wait for async operations
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then
        await MainActor.run {
            #expect(domainInteractor.currentState.showClearFavoriteMoviesAlert)
            // StorageService.clearFavoriteMovies is called directly by the interactor
        }
    }

    // MARK: - UI State Tests

    @Test("Show photo picker updates presentation state")
    func showPhotoPicker() async {
        // Given
        let (domainInteractor, _) = createTestComponents()

        // When
        await MainActor.run {
            domainInteractor.handleAction(.showPhotoPicker)
        }

        // Then
        await MainActor.run {
            #expect(domainInteractor.currentState.isPhotoPickerPresented)
        }
    }

    @Test("Hide photo picker updates presentation state")
    func hidePhotoPicker() async {
        // Given
        let (domainInteractor, _) = createTestComponents()

        await MainActor.run {
            domainInteractor.handleAction(.showPhotoPicker)
            #expect(domainInteractor.currentState.isPhotoPickerPresented)
        }

        // When
        await MainActor.run {
            domainInteractor.handleAction(.hidePhotoPicker)
        }

        // Then
        await MainActor.run {
            #expect(!domainInteractor.currentState.isPhotoPickerPresented)
        }
    }

    @Test("Show clear favorite movies confirmation updates state")
    func showClearFavoriteMoviesConfirmation() async {
        // Given
        let (domainInteractor, _) = createTestComponents()

        // When
        await MainActor.run {
            domainInteractor.handleAction(.showClearFavoriteMoviesConfirmation)
        }

        // Then
        await MainActor.run {
            #expect(domainInteractor.currentState.isClearFavoriteMoviesConfirmationPresented)
        }
    }

    @Test("Hide clear favorite movies confirmation updates state")
    func hideClearFavoriteMoviesConfirmation() async {
        // Given
        let (domainInteractor, _) = createTestComponents()

        await MainActor.run {
            domainInteractor.handleAction(.showClearFavoriteMoviesConfirmation)
            #expect(domainInteractor.currentState.isClearFavoriteMoviesConfirmationPresented)
        }

        // When
        await MainActor.run {
            domainInteractor.handleAction(.hideClearFavoriteMoviesConfirmation)
        }

        // Then
        await MainActor.run {
            #expect(!domainInteractor.currentState.isClearFavoriteMoviesConfirmationPresented)
        }
    }

    // MARK: - Error Handling Tests

    @Test("Save profile image error updates state with error message")
    func saveProfileImageError() async throws {
        // Given
        let (domainInteractor, mockSettingsService) = createTestComponents()
        mockSettingsService.shouldFailSaveProfileImage = true
        let testImage = UIImage(systemName: "person.fill")!

        // When
        await MainActor.run {
            domainInteractor.handleAction(.saveProfileImage(testImage))
        }

        // Wait for async operations
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then
        await MainActor.run {
            let state = domainInteractor.currentState
            #expect(state.error != nil)
            #expect(!(state.error?.isEmpty ?? true))
        }
    }

    @Test("Clear favorite movies error updates state with error message")
    func clearFavoriteMoviesError() async throws {
        // Given
        let mockSettingsService = MockSettingsService()
        let mockStorageService = MockStorageService()
        mockStorageService.shouldSimulateErrors = true
        mockStorageService.clearError = NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Clear failed"])

        let serviceLocator = ServiceLocator()
        serviceLocator.register(SettingsService.self, instance: mockSettingsService)
        serviceLocator.register(StorageService.self, instance: mockStorageService)

        let domainInteractor = SettingsDomainInteractor(
            serviceLocator: serviceLocator,
            initialState: SettingsDomainState.initial,
            shouldLoadInitialData: false
        )

        // When
        await MainActor.run {
            domainInteractor.handleAction(.clearAllFavoriteMovies)
        }

        // Wait for async operations
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then
        await MainActor.run {
            let state = domainInteractor.currentState
            #expect(state.error != nil)
            #expect(!(state.error?.isEmpty ?? true))
        }
    }

    // MARK: - CombineInteractor Protocol Tests

    @Test("Interact with upstream publisher processes actions correctly")
    func interactWithUpstream() async throws {
        // Given
        let (domainInteractor, _) = createTestComponents()
        let actions = [SettingsDomainAction.showPhotoPicker, SettingsDomainAction.hidePhotoPicker]
        let publisher = actions.publisher.eraseToAnyPublisher()
        var cancellables: Set<AnyCancellable> = []

        // When
        await MainActor.run {
            let statePublisher = domainInteractor.interact(upstream: publisher)
            statePublisher.sink { _ in }.store(in: &cancellables)
        }

        // Wait for actions to process
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Then
        await MainActor.run {
            #expect(!domainInteractor.currentState.isPhotoPickerPresented)
        }
    }
}
