//
//  SettingsViewModel.swift
//  GitHubApp
//
//  Created by bruno on settings functionality.
//

import Combine
import EntropyCore
import Foundation
import UIKit

/**
 * ViewModel for the Settings screen using Clean Architecture principles.
 *
 * This ViewModel now follows Clean Architecture by:
 * - Using CombineViewModel from EntropyCore
 * - Having a single source of truth through viewState
 * - Delegating business logic to SettingsDomainInteractor
 * - Converting view events to domain actions
 * - Converting domain state to view state
 *
 * Uses Combine for reactive programming and state management.
 */
@MainActor
final class SettingsViewModel: CombineViewModel {
    /// Single source of truth for the view state
    @Published var viewState: SettingsViewState = .loading

    // MARK: - CombineViewModel Requirements

    /// Type alias for the view event type
    typealias ViewEventType = SettingsViewEvent

    /// Type alias for the view state type
    typealias ViewStateType = SettingsViewState

    // MARK: - Dependencies

    /// Domain interactor handling business logic
    private let domainInteractor: SettingsDomainInteractor

    /// Reducer for converting domain state to view state
    private let viewStateReducer: SettingsViewStateReducing

    /// Service locator for dependency management
    private let serviceLocator: ServiceLocator

    // MARK: - Initialization

    /**
     * Initialize the ViewModel with dependencies.
     *
     * - Parameter serviceLocator: Service locator for dependency injection
     * - Parameter domainInteractor: Optional domain interactor (created if not provided)
     * - Parameter viewStateReducer: Optional view state reducer (created if not provided)
     */
    init(
        serviceLocator: ServiceLocator,
        domainInteractor: SettingsDomainInteractor? = nil,
        viewStateReducer: SettingsViewStateReducing? = nil
    ) {
        // Store serviceLocator for dependency resolution
        self.serviceLocator = serviceLocator

        // Initialize domain interactor
        self.domainInteractor = domainInteractor ?? SettingsDomainInteractor(
            serviceLocator: serviceLocator
        )

        // Initialize view state reducer
        self.viewStateReducer = viewStateReducer ?? SettingsViewStateReducer()

        // Set up state observation
        setupStateObservation()

        // Load initial data
        loadInitialData()
    }

    // MARK: - CombineViewModel Implementation

    /**
     * Handle incoming view events and delegate to domain interactor.
     *
     * This method implements the CombineViewModel protocol by processing view events,
     * converting them to domain actions, and sending them to the domain interactor.
     *
     * - Parameter event: The view event to handle
     */
    func handle(_ event: SettingsViewEvent) {
        let domainAction = SettingsDomainEventActionMap.map(event)
        domainInteractor.handleAction(domainAction)
    }

    /**
     * Send view event - required by CombineViewModel protocol.
     *
     * This method is the protocol requirement for sending view events.
     *
     * - Parameter event: The view event to send
     */
    func sendViewEvent(_ event: SettingsViewEvent) {
        handle(event)
    }

    // MARK: - Public Interface Methods

    /**
     * Handle profile image selection.
     *
     * Delegates to domain interactor through view event handling.
     *
     * - Parameter image: The selected image
     */
    func handleProfileImageSelection(_ image: UIImage) {
        handle(.profileImageSelected(image))
    }

    /**
     * Clear profile image.
     *
     * Delegates to domain interactor through view event handling.
     */
    func clearProfileImage() {
        handle(.clearProfileImageTapped)
    }

    /**
     * Rate the app.
     *
     * Delegates to domain interactor through view event handling.
     */
    func rateApp() {
        handle(.rateAppTapped)
    }

    /**
     * Clear all favorite movies.
     *
     * Delegates to domain interactor through view event handling.
     */
    func clearAllFavoriteMovies() {
        handle(.clearFavoriteMoviesConfirmed)
    }

    /**
     * Show photo picker.
     *
     * Delegates to domain interactor through view event handling.
     */
    func showPhotoPicker() {
        handle(.showPhotoPickerTapped)
    }

    /**
     * Hide photo picker.
     *
     * Delegates to domain interactor through view event handling.
     */
    func hidePhotoPicker() {
        handle(.hidePhotoPicker)
    }

    /**
     * Show clear favorite movies confirmation.
     *
     * Delegates to domain interactor through view event handling.
     */
    func showClearLikedMoviesConfirmation() {
        handle(.showClearFavoriteMoviesConfirmation)
    }

    /**
     * Hide clear favorite movies confirmation.
     *
     * Delegates to domain interactor through view event handling.
     */
    func hideClearLikedMoviesConfirmation() {
        handle(.hideClearFavoriteMoviesConfirmation)
    }

    // MARK: - Computed Properties from View State

    /**
     * Get current app version from view state.
     *
     * - Returns: App version string, or "1.0" if not in success state
     */
    var appVersion: String {
        guard case let .success(dataViewState) = viewState else {
            return "1.0"
        }
        return dataViewState.appVersion
    }

    /**
     * Get current app build number from view state.
     *
     * - Returns: App build number string, or "1" if not in success state
     */
    var appBuildNumber: String {
        guard case let .success(dataViewState) = viewState else {
            return "1"
        }
        return dataViewState.appBuildNumber
    }

    /**
     * Get current profile image from view state.
     *
     * - Returns: Profile image or nil if not available or not in success state
     */
    var profileImage: UIImage? {
        guard case let .success(dataViewState) = viewState else {
            return nil
        }
        return dataViewState.profileImage
    }

    /**
     * Check if app has been rated from view state.
     *
     * - Returns: True if app has been rated, false otherwise
     */
    var hasRatedApp: Bool {
        guard case let .success(dataViewState) = viewState else {
            return false
        }
        return dataViewState.hasRatedApp
    }

    /**
     * Check if photo picker is presented from view state.
     *
     * - Returns: True if photo picker is presented, false otherwise
     */
    var isPhotoPickerPresented: Bool {
        guard case let .success(dataViewState) = viewState else {
            return false
        }
        return dataViewState.isPhotoPickerPresented
    }

    /**
     * Check if clear favorite movies confirmation is presented from view state.
     *
     * - Returns: True if confirmation is presented, false otherwise
     */
    var isClearLikedMoviesConfirmationPresented: Bool {
        guard case let .success(dataViewState) = viewState else {
            return false
        }
        return dataViewState.showClearFavoritesConfirm
    }

    /**
     * Check if clear favorite movies alert should be shown from view state.
     *
     * - Returns: True if alert should be shown, false otherwise
     */
    var showClearLikedMoviesAlert: Bool {
        guard case let .success(dataViewState) = viewState else {
            return false
        }
        return dataViewState.showClearFavoriteMoviesAlert
    }

    /**
     * Check if rate app thanks alert should be shown from view state.
     *
     * - Returns: True if alert should be shown, false otherwise
     */
    var showRateAppThanks: Bool {
        guard case let .success(dataViewState) = viewState else {
            return false
        }
        return dataViewState.showRateAppThanks
    }

    /**
     * Get current error message from view state.
     *
     * - Returns: Error message if in error state, nil otherwise
     */
    var error: String? {
        guard case let .error(errorMessage) = viewState else {
            return nil
        }
        return errorMessage
    }

    // MARK: - Private Methods

    /**
     * Set up observation of domain state changes.
     *
     * This method observes the domain interactor's state and converts it to view state
     * using the view state reducer.
     */
    private func setupStateObservation() {
        domainInteractor.$currentState
            .map { [weak self] domainState in
                self?.viewStateReducer.reduce(domainState) ?? .loading
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$viewState)
    }

    /**
     * Load initial data with appropriate timing to ensure state observation is established.
     */
    private func loadInitialData() {
        // Use a small delay to ensure the state observation pipeline is fully set up
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) { [weak self] in
            self?.handle(.viewDidAppear)
        }
    }

    /**
     * Cleanup method called when ViewModel is deallocated.
     *
     * Logs deallocation for debugging purposes.
     */
    deinit {
        Logger.shared.viewModel("SettingsViewModel deallocated", level: .debug)
    }
}
