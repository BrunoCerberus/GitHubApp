//
//  SettingsManager.swift
//  GitHubApp
//
//  Created by bruno on settings functionality.
//

import Foundation
import PhotosUI
import UIKit

/**
 * Settings manager for handling app settings and user preferences.
 *
 * This class manages:
 * - Profile image storage and retrieval
 * - App rating status
 * - User preferences
 */
final class SettingsManager: ObservableObject {
    /// Published profile image for SwiftUI updates
    @Published var profileImage: UIImage?

    /// Published app rating status
    @Published var hasRatedApp: Bool = false

    /// UserDefaults keys
    private enum Keys {
        static let profileImageData = "profileImageData"
        static let hasRatedApp = "hasRatedApp"
    }

    /// Initialize the settings manager
    init() {
        loadSettings()
    }

    // MARK: - Profile Image Management

    /// Save profile image to UserDefaults
    /// - Parameter image: The image to save
    func saveProfileImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        UserDefaults.standard.set(imageData, forKey: Keys.profileImageData)
        UserDefaults.standard.synchronize()
        profileImage = image
    }

    /// Load profile image from UserDefaults
    private func loadProfileImage() {
        guard let imageData = UserDefaults.standard.data(forKey: Keys.profileImageData),
              let image = UIImage(data: imageData) else { return }

        profileImage = image
    }

    /// Clear profile image
    func clearProfileImage() {
        UserDefaults.standard.removeObject(forKey: Keys.profileImageData)
        UserDefaults.standard.synchronize()
        profileImage = nil
    }

    // MARK: - App Rating Management

    /// Mark app as rated
    func markAppAsRated() {
        hasRatedApp = true
        UserDefaults.standard.set(true, forKey: Keys.hasRatedApp)
        UserDefaults.standard.synchronize()
    }

    /// Load app rating status from UserDefaults
    private func loadAppRatingStatus() {
        hasRatedApp = UserDefaults.standard.bool(forKey: Keys.hasRatedApp)
    }

    // MARK: - Settings Loading

    /// Load all settings from UserDefaults
    private func loadSettings() {
        loadProfileImage()
        loadAppRatingStatus()
    }

    /// Clear all settings
    func clearAllSettings() {
        clearProfileImage()
        UserDefaults.standard.removeObject(forKey: Keys.hasRatedApp)
        UserDefaults.standard.synchronize()

        // Reset to defaults
        hasRatedApp = false
        profileImage = nil
    }
}
