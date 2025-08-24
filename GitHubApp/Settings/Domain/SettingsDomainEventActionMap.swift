//
//  SettingsDomainEventActionMap.swift
//  GitHubApp
//
//  Created by bruno on feature/settings-clean-architecture.
//

import Foundation

/**
 * Maps view events to domain actions for the Settings feature.
 *
 * This mapper provides a clean separation between view events (user intentions)
 * and domain actions (business operations), following Clean Architecture principles.
 */
enum SettingsDomainEventActionMap {
    /**
     * Map a view event to a domain action.
     *
     * This method converts user intentions from the view layer
     * into business actions for the domain layer.
     *
     * - Parameter event: The view event to map
     * - Returns: The corresponding domain action
     */
    static func map(_ event: SettingsViewEvent) -> SettingsDomainAction {
        switch event {
        case .viewDidAppear:
            .loadSettings
        case let .profileImageSelected(image):
            .saveProfileImage(image)
        case .clearProfileImageTapped:
            .clearProfileImage
        case .rateAppTapped:
            .rateApp
        case .clearFavoriteMoviesTapped:
            .showClearFavoriteMoviesConfirmation
        case .clearFavoriteMoviesConfirmed:
            .clearAllFavoriteMovies
        case .showPhotoPickerTapped:
            .showPhotoPicker
        case .hidePhotoPicker:
            .hidePhotoPicker
        case .showClearFavoriteMoviesConfirmation:
            .showClearFavoriteMoviesConfirmation
        case .hideClearFavoriteMoviesConfirmation:
            .hideClearFavoriteMoviesConfirmation
        }
    }
}
