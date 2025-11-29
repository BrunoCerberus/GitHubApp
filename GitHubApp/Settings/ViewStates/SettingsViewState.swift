//
//  SettingsViewState.swift
//  GitHubApp
//
//  Created by bruno on feature/settings-clean-architecture.
//

import Foundation
import UIKit

/**
 * High-level UI state for the Settings view.
 */
enum SettingsViewState: Equatable {
    /// Data is currently loading
    case loading
    /// Data loaded successfully with associated payload
    case success(SettingsDataViewState)
    /// An error occurred with a message to display
    case error(String)
}

/**
 * Data view state for successful Settings view state.
 *
 * This contains all the data needed to render the Settings view
 * when the view is in a success state.
 */
struct SettingsDataViewState: Equatable {
    /// Current profile image
    let profileImage: UIImage?

    /// Whether the app has been rated
    let hasRatedApp: Bool

    /// Current app version
    let appVersion: String

    /// Current app build number
    let appBuildNumber: String

    /// Photo picker presentation state
    let isPhotoPickerPresented: Bool

    /// Clear favorite movies confirmation dialog state
    let showClearFavoritesConfirm: Bool

    /// Clear favorite movies success alert state
    let showClearFavoriteMoviesAlert: Bool

    /// Rate app success alert state
    let showRateAppThanks: Bool

    static func == (lhs: SettingsDataViewState, rhs: SettingsDataViewState) -> Bool {
        let imageEqual = (lhs.profileImage == nil && rhs.profileImage == nil) ||
            (lhs.profileImage?.pngData() == rhs.profileImage?.pngData())

        return imageEqual &&
            lhs.hasRatedApp == rhs.hasRatedApp &&
            lhs.appVersion == rhs.appVersion &&
            lhs.appBuildNumber == rhs.appBuildNumber &&
            lhs.isPhotoPickerPresented == rhs.isPhotoPickerPresented &&
            lhs.showClearFavoritesConfirm == rhs.showClearFavoritesConfirm &&
            lhs.showClearFavoriteMoviesAlert == rhs.showClearFavoriteMoviesAlert &&
            lhs.showRateAppThanks == rhs.showRateAppThanks
    }
}
