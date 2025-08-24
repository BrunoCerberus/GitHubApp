//
//  SettingsDomainState.swift
//  GitHubApp
//
//  Created by bruno on feature/settings-clean-architecture.
//

import Foundation
import UIKit

/**
 * Domain state for the Settings feature business logic.
 *
 * This represents the current state of the Settings domain,
 * containing all data and status information needed by the business logic.
 */
struct SettingsDomainState: Equatable {
    /// Current profile image
    var profileImage: UIImage?

    /// Whether the app has been rated
    var hasRatedApp: Bool

    /// Current app version
    var appVersion: String

    /// Current app build number
    var appBuildNumber: String

    /// Photo picker presentation state
    var isPhotoPickerPresented: Bool

    /// Clear favorite movies confirmation dialog state
    var isClearFavoriteMoviesConfirmationPresented: Bool

    /// Clear favorite movies success alert state
    var showClearFavoriteMoviesAlert: Bool

    /// Rate app success alert state
    var showRateAppThanks: Bool

    /// Current loading state
    var isLoading: Bool

    /// Current error state
    var error: String?

    /// Default initial state
    static let initial = SettingsDomainState(
        profileImage: nil,
        hasRatedApp: false,
        appVersion: "1.0",
        appBuildNumber: "1",
        isPhotoPickerPresented: false,
        isClearFavoriteMoviesConfirmationPresented: false,
        showClearFavoriteMoviesAlert: false,
        showRateAppThanks: false,
        isLoading: false,
        error: nil
    )

    static func == (lhs: SettingsDomainState, rhs: SettingsDomainState) -> Bool {
        let imageEqual = (lhs.profileImage == nil && rhs.profileImage == nil) ||
            (lhs.profileImage?.pngData() == rhs.profileImage?.pngData())

        return imageEqual &&
            lhs.hasRatedApp == rhs.hasRatedApp &&
            lhs.appVersion == rhs.appVersion &&
            lhs.appBuildNumber == rhs.appBuildNumber &&
            lhs.isPhotoPickerPresented == rhs.isPhotoPickerPresented &&
            lhs.isClearFavoriteMoviesConfirmationPresented == rhs.isClearFavoriteMoviesConfirmationPresented &&
            lhs.showClearFavoriteMoviesAlert == rhs.showClearFavoriteMoviesAlert &&
            lhs.showRateAppThanks == rhs.showRateAppThanks &&
            lhs.isLoading == rhs.isLoading &&
            lhs.error == rhs.error
    }
}
