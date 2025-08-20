//
//  SettingsViewModelTests.swift
//  GitHubAppTests
//
//  Created by bruno on settings functionality.
//

import UIKit
import XCTest

@testable import GitHubApp

/**
 * Unit tests for SettingsViewModel functionality.
 */
@MainActor
final class SettingsViewModelTests: XCTestCase {
    var likedMoviesViewModel: LikedMoviesViewModel!
    var settingsViewModel: SettingsViewModel!

    override func setUp() {
        super.setUp()
        likedMoviesViewModel = LikedMoviesViewModel()
        settingsViewModel = SettingsViewModel(likedMoviesViewModel: likedMoviesViewModel)
    }

    override func tearDown() {
        likedMoviesViewModel = nil
        settingsViewModel = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        // Then
        XCTAssertNotNil(settingsViewModel.settingsManager)
        XCTAssertNotNil(settingsViewModel.appVersion)
        XCTAssertNotNil(settingsViewModel.appBuildNumber)
        XCTAssertFalse(settingsViewModel.isPhotoPickerPresented)
        XCTAssertFalse(settingsViewModel.isClearLikedMoviesConfirmationPresented)
        XCTAssertFalse(settingsViewModel.showClearLikedMoviesAlert)
        XCTAssertFalse(settingsViewModel.showRateAppThanks)
    }

    // MARK: - App Version Tests

    func testAppVersion() {
        // Then
        XCTAssertFalse(settingsViewModel.appVersion.isEmpty)
        XCTAssertFalse(settingsViewModel.appBuildNumber.isEmpty)
    }

    // MARK: - Liked Movies Management Tests

    func testClearAllLikedMovies() {
        // Given
        let testMovie = Movie(
            id: 1,
            title: "Test Movie",
            overview: "Test Overview",
            posterPath: "/test.jpg"
        )
        likedMoviesViewModel.toggleLike(for: testMovie)
        XCTAssertEqual(likedMoviesViewModel.likedMovies.count, 1)

        // When
        settingsViewModel.clearAllLikedMovies()

        // Then
        XCTAssertEqual(likedMoviesViewModel.likedMovies.count, 0)
        XCTAssertTrue(settingsViewModel.showClearLikedMoviesAlert)
    }

    // MARK: - App Rating Tests

    func testRateApp() {
        // Given
        XCTAssertFalse(settingsViewModel.settingsManager.hasRatedApp)

        // When
        settingsViewModel.rateApp()

        // Then
        XCTAssertTrue(settingsViewModel.settingsManager.hasRatedApp)
        XCTAssertTrue(settingsViewModel.showRateAppThanks)
    }

    // MARK: - Photo Picker Tests

    func testShowPhotoPicker() {
        // When
        settingsViewModel.showPhotoPicker()

        // Then
        XCTAssertTrue(settingsViewModel.isPhotoPickerPresented)
    }

    func testHidePhotoPicker() {
        // Given
        settingsViewModel.isPhotoPickerPresented = true

        // When
        settingsViewModel.hidePhotoPicker()

        // Then
        XCTAssertFalse(settingsViewModel.isPhotoPickerPresented)
    }

    // MARK: - Clear Liked Movies Confirmation Tests

    func testShowClearLikedMoviesConfirmation() {
        // When
        settingsViewModel.showClearLikedMoviesConfirmation()

        // Then
        XCTAssertTrue(settingsViewModel.isClearLikedMoviesConfirmationPresented)
    }

    func testHideClearLikedMoviesConfirmation() {
        // Given
        settingsViewModel.isClearLikedMoviesConfirmationPresented = true

        // When
        settingsViewModel.hideClearLikedMoviesConfirmation()

        // Then
        XCTAssertFalse(settingsViewModel.isClearLikedMoviesConfirmationPresented)
    }
}
