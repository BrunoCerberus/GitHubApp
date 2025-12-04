//
//  SettingsDomainInteractor.swift
//  GitHubApp
//
//  Created by bruno on feature/settings-clean-architecture.
//

import Combine
@preconcurrency import EntropyCore
import Foundation
import StoreKit
import UIKit

/**
 * Domain interactor for the Settings feature business logic.
 *
 * This interactor handles all business logic for the Settings feature using Clean Architecture principles.
 * It processes domain actions and manages domain state while communicating with external services.
 *
 * Conforms to CombineInteractor to leverage reactive programming patterns.
 */
@MainActor
final class SettingsDomainInteractor: ObservableObject, CombineInteractor {
    // MARK: - CombineInteractor Requirements

    /// Input type for the interactor
    typealias Input = SettingsDomainAction

    /// Input error type
    typealias InputError = Never

    /// Output type for the interactor
    typealias Output = SettingsDomainState

    /// Output error type
    typealias OutputError = Never

    /// Current state of the interactor
    @Published var currentState: SettingsDomainState

    // MARK: - Dependencies

    /// Service for settings operations
    private let settingsService: SettingsService

    /// Storage service for persisting favorite movies
    private let storageService: StorageService

    /// Combine cancellables for memory management
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initialization

    /**
     * Initialize the domain interactor with required dependencies.
     *
     * - Parameter serviceLocator: Service locator for dependency injection
     * - Parameter initialState: Initial domain state (defaults to SettingsDomainState.initial)
     * - Parameter shouldLoadInitialData: Whether to load initial data automatically
     */
    init(
        serviceLocator: ServiceLocator,
        initialState: SettingsDomainState = .initial,
        shouldLoadInitialData: Bool = true
    ) {
        // Retrieve SettingsService from ServiceLocator
        do {
            settingsService = try serviceLocator.retrieve(SettingsService.self)
        } catch {
            Logger.shared.service("Failed to retrieve SettingsService from ServiceLocator: \(error)", level: .warning)
            settingsService = LiveSettingsService()
        }

        // Retrieve StorageService from ServiceLocator
        do {
            storageService = try serviceLocator.retrieve(StorageService.self)
        } catch {
            Logger.shared.service("Failed to retrieve StorageService from ServiceLocator: \(error)", level: .warning)
            // swiftlint:disable:next force_try
            storageService = try! LiveStorageService()
        }

        currentState = initialState

        // Load initial data if requested
        if shouldLoadInitialData {
            loadInitialSettings()
        }
    }

    // MARK: - CombineInteractor Implementation

    /**
     * Interact method required by CombineInteractor protocol.
     *
     * This method processes the input stream of actions and returns the output state stream.
     *
     * - Parameter upstream: Publisher of domain actions
     * - Returns: Publisher of domain states
     */
    func interact(upstream: AnyPublisher<SettingsDomainAction, Never>) -> AnyPublisher<SettingsDomainState, Never> {
        upstream
            .sink { [weak self] action in
                self?.handleAction(action)
            }
            .store(in: &cancellables)

        return $currentState
            .eraseToAnyPublisher()
    }

    /**
     * Process domain actions and update state accordingly.
     *
     * This method handles all business logic by processing actions and
     * producing appropriate state changes through reactive streams.
     *
     * - Parameter action: The domain action to process
     */
    func handleAction(_ action: SettingsDomainAction) {
        switch action {
        case .loadSettings:
            handleLoadSettings()
        case let .saveProfileImage(image):
            handleSaveProfileImage(image)
        case .clearProfileImage:
            handleClearProfileImage()
        case .rateApp:
            handleRateApp()
        case .clearAllFavoriteMovies:
            handleClearAllFavoriteMovies()
        case .showPhotoPicker:
            handleShowPhotoPicker()
        case .hidePhotoPicker:
            handleHidePhotoPicker()
        case .showClearFavoriteMoviesConfirmation:
            handleShowClearFavoriteMoviesConfirmation()
        case .hideClearFavoriteMoviesConfirmation:
            handleHideClearFavoriteMoviesConfirmation()
        }
    }

    // MARK: - Private Action Handlers

    /**
     * Handle loading settings from storage.
     */
    private func handleLoadSettings() {
        currentState = currentState.copy(isLoading: true, error: nil)

        Publishers.CombineLatest3(
            settingsService.loadProfileImage(),
            settingsService.hasRatedApp(),
            settingsService.getAppVersionInfo()
        )
        .sink { [weak self] profileImage, hasRatedApp, versionInfo in
            self?.currentState = self?.currentState.withProfileImage(profileImage).copy(
                hasRatedApp: hasRatedApp,
                appVersion: versionInfo.version,
                appBuildNumber: versionInfo.buildNumber,
                isLoading: false
            ) ?? SettingsDomainState.initial
        }
        .store(in: &cancellables)
    }

    /**
     * Handle saving profile image.
     *
     * - Parameter image: The image to save
     */
    private func handleSaveProfileImage(_ image: UIImage) {
        settingsService.saveProfileImage(image)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.currentState = self?.currentState.copy(
                            error: error.localizedDescription
                        ) ?? SettingsDomainState.initial
                    }
                },
                receiveValue: { [weak self] in
                    self?.currentState = self?.currentState.withProfileImage(image).copy(
                        error: nil
                    ) ?? SettingsDomainState.initial
                }
            )
            .store(in: &cancellables)
    }

    /**
     * Handle clearing profile image.
     */
    private func handleClearProfileImage() {
        settingsService.clearProfileImage()
            .sink { [weak self] in
                self?.currentState = self?.currentState.withProfileImage(nil).copy(
                    error: nil
                ) ?? SettingsDomainState.initial
            }
            .store(in: &cancellables)
    }

    /**
     * Handle app rating request.
     */
    private func handleRateApp() {
        // Only proceed if the app hasn't been rated yet
        guard !currentState.hasRatedApp else { return }

        // Request app review using the appropriate API based on iOS version
        Task { @MainActor in
            if #available(iOS 18.0, *) {
                // Use new AppStore.requestReview API (iOS 18.0+)
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    // Only request review in production builds, not in test environments
                    Logger.shared.domain("Requesting app review using AppStore API", level: .debug)
                    AppStore.requestReview(in: scene)
                }
            } else {
                // Fallback for older iOS versions
                if let url = URL(string: "https://apps.apple.com/app/id1234567890") {
                    UIApplication.shared.open(url)
                }
            }
        }

        // Mark app as rated
        settingsService.markAppAsRated()
            .sink { [weak self] in
                self?.currentState = self?.currentState.copy(
                    hasRatedApp: true,
                    showRateAppThanks: true
                ) ?? SettingsDomainState.initial

                // Hide thanks message after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    self?.currentState = self?.currentState.copy(
                        showRateAppThanks: false
                    ) ?? SettingsDomainState.initial
                }
            }
            .store(in: &cancellables)
    }

    /**
     * Handle clearing all favorite movies.
     */
    private func handleClearAllFavoriteMovies() {
        Task {
            do {
                // Use StorageService to clear favorite movies (bridge between services)
                try await storageService.clearFavoriteMovies()

                await MainActor.run {
                    currentState = currentState.copy(
                        showClearFavoriteMoviesAlert: true,
                        error: nil
                    )
                }

                // Post notification to notify other features about the change
                NotificationCenter.default.post(name: .favoriteMoviesDidUpdate, object: nil)
            } catch {
                await MainActor.run {
                    currentState = currentState.copy(
                        error: error.localizedDescription
                    )
                }
            }
        }
    }

    /**
     * Handle showing photo picker.
     */
    private func handleShowPhotoPicker() {
        currentState = currentState.copy(isPhotoPickerPresented: true)
    }

    /**
     * Handle hiding photo picker.
     */
    private func handleHidePhotoPicker() {
        currentState = currentState.copy(isPhotoPickerPresented: false)
    }

    /**
     * Handle showing clear favorite movies confirmation.
     */
    private func handleShowClearFavoriteMoviesConfirmation() {
        currentState = currentState.copy(showClearFavoritesConfirm: true)
    }

    /**
     * Handle hiding clear favorite movies confirmation.
     */
    private func handleHideClearFavoriteMoviesConfirmation() {
        currentState = currentState.copy(showClearFavoritesConfirm: false)
    }

    // MARK: - Private Helper Methods

    /**
     * Load initial settings on startup.
     */
    private func loadInitialSettings() {
        handleLoadSettings()
    }
}

// MARK: - SettingsDomainState Helper Extension

extension SettingsDomainState {
    /**
     * Create a copy of the current state with modified properties.
     */
    func copy(
        profileImage: UIImage?? = nil,
        hasRatedApp: Bool? = nil,
        appVersion: String? = nil,
        appBuildNumber: String? = nil,
        isPhotoPickerPresented: Bool? = nil,
        showClearFavoritesConfirm: Bool? = nil,
        showClearFavoriteMoviesAlert: Bool? = nil,
        showRateAppThanks: Bool? = nil,
        isLoading: Bool? = nil,
        error: String? = nil
    ) -> SettingsDomainState {
        SettingsDomainState(
            profileImage: profileImage ?? self.profileImage,
            hasRatedApp: hasRatedApp ?? self.hasRatedApp,
            appVersion: appVersion ?? self.appVersion,
            appBuildNumber: appBuildNumber ?? self.appBuildNumber,
            isPhotoPickerPresented: isPhotoPickerPresented ?? self.isPhotoPickerPresented,
            showClearFavoritesConfirm:
            showClearFavoritesConfirm ?? self.showClearFavoritesConfirm,
            showClearFavoriteMoviesAlert: showClearFavoriteMoviesAlert ?? self.showClearFavoriteMoviesAlert,
            showRateAppThanks: showRateAppThanks ?? self.showRateAppThanks,
            isLoading: isLoading ?? self.isLoading,
            error: error ?? self.error
        )
    }

    /**
     * Create a copy with a new profile image.
     */
    func withProfileImage(_ profileImage: UIImage?) -> SettingsDomainState {
        SettingsDomainState(
            profileImage: profileImage,
            hasRatedApp: hasRatedApp,
            appVersion: appVersion,
            appBuildNumber: appBuildNumber,
            isPhotoPickerPresented: isPhotoPickerPresented,
            showClearFavoritesConfirm: showClearFavoritesConfirm,
            showClearFavoriteMoviesAlert: showClearFavoriteMoviesAlert,
            showRateAppThanks: showRateAppThanks,
            isLoading: isLoading,
            error: error
        )
    }
}
