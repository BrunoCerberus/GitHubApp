//
//  SettingsViewModel.swift
//  GitHubApp
//
//  Created by bruno on settings functionality.
//

import Foundation
import PhotosUI
import StoreKit
import UIKit

/**
 * ViewModel for managing settings functionality.
 *
 * This ViewModel handles:
 * - Profile image selection and management
 * - Language selection
 * - App rating functionality
 * - Clearing liked movies
 * - Settings persistence
 */
final class SettingsViewModel: ObservableObject {
    /// Settings manager for handling settings
    @Published var settingsManager: SettingsManager

    /// Liked movies view model for clearing liked movies
    private let likedMoviesViewModel: LikedMoviesViewModel

    /// Current app version
    let appVersion: String

    /// Current app build number
    let appBuildNumber: String

    /// Show photo picker
    @Published var isPhotoPickerPresented = false

    /// Show clear liked movies confirmation
    @Published var isClearLikedMoviesConfirmationPresented = false

    /// Show clear liked movies alert
    @Published var showClearLikedMoviesAlert = false

    /// Show rate app thanks message
    @Published var showRateAppThanks = false

    /// Initialize the settings view model
    /// - Parameter likedMoviesViewModel: View model for managing liked movies
    init(likedMoviesViewModel: LikedMoviesViewModel) {
        self.likedMoviesViewModel = likedMoviesViewModel
        settingsManager = SettingsManager()

        // Get app version and build number
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        {
            appVersion = version
            appBuildNumber = build
        } else {
            appVersion = "1.0"
            appBuildNumber = "1"
        }
    }

    // MARK: - Profile Image Management

    /// Handle profile image selection
    /// - Parameter image: The selected image
    func handleProfileImageSelection(_ image: UIImage) {
        settingsManager.saveProfileImage(image)
    }

    /// Clear profile image
    func clearProfileImage() {
        settingsManager.clearProfileImage()
    }

    // MARK: - Liked Movies Management

    /// Clear all liked movies
    func clearAllLikedMovies() {
        // Clear liked movies from the view model
        likedMoviesViewModel.clearAllLikedMovies()

        // Show confirmation
        showClearLikedMoviesAlert = true

        // Hide confirmation after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.showClearLikedMoviesAlert = false
        }
    }

    // MARK: - App Rating

    /// Rate the app
    func rateApp() {
        // Only proceed if the app hasn't been rated yet
        guard !settingsManager.hasRatedApp else { return }

        // Request app review (iOS 14.0+)
        if #available(iOS 14.0, *) {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                // Only request review in production builds, not in test environments
                #if DEBUG
                    // In debug/test builds, just show the thanks message without requesting review
                    print("DEBUG: Skipping app review request in debug/test build")
                #else
                    SKStoreReviewController.requestReview(in: scene)
                #endif
            }
        } else {
            // Fallback for older iOS versions
            if let url = URL(string: "https://apps.apple.com/app/id1234567890") {
                UIApplication.shared.open(url)
            }
        }

        // Mark app as rated after requesting review
        settingsManager.markAppAsRated()

        // Show thanks message
        showRateAppThanks = true

        // Hide thanks message after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.showRateAppThanks = false
        }
    }

    // MARK: - Photo Picker

    /// Show photo picker
    func showPhotoPicker() {
        isPhotoPickerPresented = true
    }

    /// Hide photo picker
    func hidePhotoPicker() {
        isPhotoPickerPresented = false
    }

    // MARK: - Clear Liked Movies Confirmation

    /// Show clear liked movies confirmation
    func showClearLikedMoviesConfirmation() {
        isClearLikedMoviesConfirmationPresented = true
    }

    /// Hide clear liked movies confirmation
    func hideClearLikedMoviesConfirmation() {
        isClearLikedMoviesConfirmationPresented = false
    }
}
