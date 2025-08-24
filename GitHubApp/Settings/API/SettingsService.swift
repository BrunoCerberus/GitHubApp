//
//  SettingsService.swift
//  GitHubApp
//
//  Created by bruno on feature/settings-clean-architecture.
//

import Combine
import Foundation
import UIKit

/**
 * Protocol for settings-related operations.
 *
 * This protocol abstracts the settings data operations,
 * providing a clean interface between the domain layer and persistence.
 */
protocol SettingsService {
    /**
     * Load profile image from storage.
     *
     * - Returns: Publisher that emits the profile image or nil if not found
     */
    func loadProfileImage() -> AnyPublisher<UIImage?, Never>

    /**
     * Save profile image to storage.
     *
     * - Parameter image: The image to save
     * - Returns: Publisher that completes when the operation is finished
     */
    func saveProfileImage(_ image: UIImage) -> AnyPublisher<Void, Error>

    /**
     * Clear profile image from storage.
     *
     * - Returns: Publisher that completes when the operation is finished
     */
    func clearProfileImage() -> AnyPublisher<Void, Never>

    /**
     * Check if app has been rated.
     *
     * - Returns: Publisher that emits the rating status
     */
    func hasRatedApp() -> AnyPublisher<Bool, Never>

    /**
     * Mark app as rated.
     *
     * - Returns: Publisher that completes when the operation is finished
     */
    func markAppAsRated() -> AnyPublisher<Void, Never>

    /**
     * Clear all favorite movies.
     *
     * - Returns: Publisher that completes when the operation is finished
     */
    func clearAllFavoriteMovies() -> AnyPublisher<Void, Error>

    /**
     * Get app version information.
     *
     * - Returns: Publisher that emits version and build number
     */
    func getAppVersionInfo() -> AnyPublisher<(version: String, buildNumber: String), Never>
}
