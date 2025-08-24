//
//  SettingsDomainAction.swift
//  GitHubApp
//
//  Created by bruno on feature/settings-clean-architecture.
//

import Foundation
import UIKit

/**
 * Domain actions for the Settings feature business logic.
 *
 * These actions represent the business operations that can be performed
 * within the Settings domain, independent of UI concerns.
 */
enum SettingsDomainAction: Equatable {
    case loadSettings
    case saveProfileImage(UIImage)
    case clearProfileImage
    case rateApp
    case clearAllFavoriteMovies
    case showPhotoPicker
    case hidePhotoPicker
    case showClearFavoriteMoviesConfirmation
    case hideClearFavoriteMoviesConfirmation

    static func == (lhs: SettingsDomainAction, rhs: SettingsDomainAction) -> Bool {
        switch (lhs, rhs) {
        case (.loadSettings, .loadSettings),
             (.clearProfileImage, .clearProfileImage),
             (.rateApp, .rateApp),
             (.clearAllFavoriteMovies, .clearAllFavoriteMovies),
             (.showPhotoPicker, .showPhotoPicker),
             (.hidePhotoPicker, .hidePhotoPicker),
             (.showClearFavoriteMoviesConfirmation, .showClearFavoriteMoviesConfirmation),
             (.hideClearFavoriteMoviesConfirmation, .hideClearFavoriteMoviesConfirmation):
            true
        case let (.saveProfileImage(lhsImage), .saveProfileImage(rhsImage)):
            lhsImage.pngData() == rhsImage.pngData()
        default:
            false
        }
    }
}
