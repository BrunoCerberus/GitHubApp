//
//  SettingsViewEvent.swift
//  GitHubApp
//
//  Created by bruno on feature/settings-clean-architecture.
//

import Foundation
import UIKit

/**
 * User/intention events originating from the Settings view.
 */
enum SettingsViewEvent: Equatable {
    case viewDidAppear
    case profileImageSelected(UIImage)
    case clearProfileImageTapped
    case rateAppTapped
    case clearFavoriteMoviesTapped
    case clearFavoriteMoviesConfirmed
    case showPhotoPickerTapped
    case hidePhotoPicker
    case showClearFavoriteMoviesConfirmation
    case hideClearFavoriteMoviesConfirmation

    static func == (lhs: SettingsViewEvent, rhs: SettingsViewEvent) -> Bool {
        switch (lhs, rhs) {
        case (.viewDidAppear, .viewDidAppear),
             (.clearProfileImageTapped, .clearProfileImageTapped),
             (.rateAppTapped, .rateAppTapped),
             (.clearFavoriteMoviesTapped, .clearFavoriteMoviesTapped),
             (.clearFavoriteMoviesConfirmed, .clearFavoriteMoviesConfirmed),
             (.showPhotoPickerTapped, .showPhotoPickerTapped),
             (.hidePhotoPicker, .hidePhotoPicker),
             (.showClearFavoriteMoviesConfirmation, .showClearFavoriteMoviesConfirmation),
             (.hideClearFavoriteMoviesConfirmation, .hideClearFavoriteMoviesConfirmation):
            true
        case let (.profileImageSelected(lhsImage), .profileImageSelected(rhsImage)):
            lhsImage.pngData() == rhsImage.pngData()
        default:
            false
        }
    }
}
