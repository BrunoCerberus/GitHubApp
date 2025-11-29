//
//  SettingsViewStateReducing.swift
//  GitHubApp
//
//  Created by bruno on feature/settings-clean-architecture.
//

import Foundation

/**
 * Protocol for reducing domain state to view state.
 *
 * This protocol defines the contract for converting domain state
 * to view state, following the Clean Architecture pattern.
 */
protocol SettingsViewStateReducing {
    /**
     * Reduce domain state to view state.
     *
     * - Parameter domainState: The current domain state
     * - Returns: The corresponding view state
     */
    func reduce(_ domainState: SettingsDomainState) -> SettingsViewState
}

/**
 * Concrete implementation of SettingsViewStateReducing.
 *
 * This reducer converts domain state to view state for the Settings feature.
 */
struct SettingsViewStateReducer: SettingsViewStateReducing {
    /**
     * Reduce domain state to view state.
     *
     * This method converts the domain state to the appropriate view state
     * based on loading status, error conditions, and data availability.
     *
     * - Parameter domainState: The current domain state
     * - Returns: The corresponding view state
     */
    func reduce(_ domainState: SettingsDomainState) -> SettingsViewState {
        // Check for error state
        if let error = domainState.error {
            return .error(error)
        }

        // Check for loading state
        if domainState.isLoading {
            return .loading
        }

        // Create success state with data
        let dataViewState = SettingsDataViewState(
            profileImage: domainState.profileImage,
            hasRatedApp: domainState.hasRatedApp,
            appVersion: domainState.appVersion,
            appBuildNumber: domainState.appBuildNumber,
            isPhotoPickerPresented: domainState.isPhotoPickerPresented,
            showClearFavoritesConfirm: domainState.showClearFavoritesConfirm,
            showClearFavoriteMoviesAlert: domainState.showClearFavoriteMoviesAlert,
            showRateAppThanks: domainState.showRateAppThanks
        )

        return .success(dataViewState)
    }
}
