//
//  SettingsManagerTests.swift
//  GitHubAppTests
//
//  Created by bruno on settings functionality.
//

import UIKit
import XCTest

@testable import GitHubApp

/**
 * Unit tests for SettingsManager functionality.
 */
final class SettingsManagerTests: XCTestCase {
    var settingsManager: SettingsManager!

    override func setUp() {
        super.setUp()

        // Clear specific UserDefaults keys for clean testing
        UserDefaults.standard.removeObject(forKey: "profileImageData")
        UserDefaults.standard.removeObject(forKey: "hasRatedApp")
        UserDefaults.standard.synchronize()

        settingsManager = SettingsManager()
    }

    override func tearDown() {
        // Clear specific UserDefaults keys after each test
        UserDefaults.standard.removeObject(forKey: "profileImageData")
        UserDefaults.standard.removeObject(forKey: "hasRatedApp")
        UserDefaults.standard.synchronize()

        settingsManager = nil
        super.tearDown()
    }

    // MARK: - Profile Image Tests

    func testSaveAndLoadProfileImage() {
        // Given
        let testImage = UIImage(systemName: "person.fill") ?? UIImage()

        // When
        settingsManager.saveProfileImage(testImage)

        // Then
        XCTAssertNotNil(settingsManager.profileImage)
    }

    func testClearProfileImage() {
        // Given
        let testImage = UIImage(systemName: "person.fill") ?? UIImage()
        settingsManager.saveProfileImage(testImage)
        XCTAssertNotNil(settingsManager.profileImage)

        // When
        settingsManager.clearProfileImage()

        // Then
        XCTAssertNil(settingsManager.profileImage)
    }

    func testProfileImagePersistence() {
        // Given
        let testImage = UIImage(systemName: "person.fill") ?? UIImage()
        settingsManager.saveProfileImage(testImage)
        XCTAssertNotNil(settingsManager.profileImage)

        // When
        let newSettingsManager = SettingsManager()

        // Then
        XCTAssertNotNil(newSettingsManager.profileImage)
    }

    // MARK: - App Rating Tests

    func testMarkAppAsRated() {
        // Given
        XCTAssertFalse(settingsManager.hasRatedApp)

        // When
        settingsManager.markAppAsRated()

        // Then
        XCTAssertTrue(settingsManager.hasRatedApp)
    }

    func testAppRatingPersistence() {
        // Given
        settingsManager.markAppAsRated()
        XCTAssertTrue(settingsManager.hasRatedApp)

        // When
        let newSettingsManager = SettingsManager()

        // Then
        XCTAssertTrue(newSettingsManager.hasRatedApp)
    }

    // MARK: - Clear All Settings Tests

    func testClearAllSettings() {
        // Given
        let testImage = UIImage(systemName: "person.fill") ?? UIImage()
        settingsManager.saveProfileImage(testImage)
        settingsManager.markAppAsRated()

        // Verify settings are set
        XCTAssertNotNil(settingsManager.profileImage)
        XCTAssertTrue(settingsManager.hasRatedApp)

        // When
        settingsManager.clearAllSettings()

        // Then
        XCTAssertNil(settingsManager.profileImage)
        XCTAssertFalse(settingsManager.hasRatedApp)
    }
}
