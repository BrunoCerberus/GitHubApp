//
//  SettingsManagerTests.swift
//  GitHubAppTests
//
//  Created by bruno on settings functionality.
//

@testable import GitHubApp
import Testing
import UIKit

@MainActor
struct SettingsManagerTests {
    // MARK: - Profile Image Tests

    @Test("Profile image can be saved and loaded from settings")
    func saveAndLoadProfileImage() {
        defer { cleanup() }

        // Given
        let settingsManager = createSettingsManager()
        let testImage = UIImage(systemName: "person.fill") ?? UIImage()

        // When
        settingsManager.saveProfileImage(testImage)

        // Then
        #expect(settingsManager.profileImage != nil)
    }

    @Test("Profile image can be cleared from settings")
    func clearProfileImage() {
        defer { cleanup() }

        // Given
        let settingsManager = createSettingsManager()
        let testImage = UIImage(systemName: "person.fill") ?? UIImage()
        settingsManager.saveProfileImage(testImage)
        #expect(settingsManager.profileImage != nil)

        // When
        settingsManager.clearProfileImage()

        // Then
        #expect(settingsManager.profileImage == nil)
    }

    @Test("Profile image persists across SettingsManager instances")
    func profileImagePersistence() {
        defer { cleanup() }

        // Given
        let settingsManager = createSettingsManager()
        let testImage = UIImage(systemName: "person.fill") ?? UIImage()
        settingsManager.saveProfileImage(testImage)
        #expect(settingsManager.profileImage != nil)

        // When
        let newSettingsManager = SettingsManager()

        // Then
        #expect(newSettingsManager.profileImage != nil)
    }

    // MARK: - App Rating Tests

    @Test("App can be marked as rated in settings")
    func markAppAsRated() {
        defer { cleanup() }

        // Given
        let settingsManager = createSettingsManager()
        #expect(!settingsManager.hasRatedApp)

        // When
        settingsManager.markAppAsRated()

        // Then
        #expect(settingsManager.hasRatedApp)
    }

    @Test("App rating status persists across SettingsManager instances")
    func appRatingPersistence() {
        defer { cleanup() }

        // Given
        let settingsManager = createSettingsManager()
        settingsManager.markAppAsRated()
        #expect(settingsManager.hasRatedApp)

        // When
        let newSettingsManager = SettingsManager()

        // Then
        #expect(newSettingsManager.hasRatedApp)
    }

    // MARK: - Clear All Settings Tests

    @Test("Clear all settings removes all stored data")
    func clearAllSettings() {
        defer { cleanup() }

        // Given
        let settingsManager = createSettingsManager()
        let testImage = UIImage(systemName: "person.fill") ?? UIImage()
        settingsManager.saveProfileImage(testImage)
        settingsManager.markAppAsRated()

        // Verify settings are set
        #expect(settingsManager.profileImage != nil)
        #expect(settingsManager.hasRatedApp)

        // When
        settingsManager.clearAllSettings()

        // Then
        #expect(settingsManager.profileImage == nil)
        #expect(!settingsManager.hasRatedApp)
    }

    // MARK: - Helper Methods

    private func createSettingsManager() -> SettingsManager {
        // Clear specific UserDefaults keys for clean testing
        UserDefaults.standard.removeObject(forKey: "profileImageData")
        UserDefaults.standard.removeObject(forKey: "hasRatedApp")
        UserDefaults.standard.synchronize()

        return SettingsManager()
    }

    private func cleanup() {
        // Clear specific UserDefaults keys after each test
        UserDefaults.standard.removeObject(forKey: "profileImageData")
        UserDefaults.standard.removeObject(forKey: "hasRatedApp")
        UserDefaults.standard.synchronize()
    }
}
