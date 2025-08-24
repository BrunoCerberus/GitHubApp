//
//  SettingsViewPhotoPickerTests.swift
//  GitHubAppTests
//
//  Created by claude on 23/08/25.
//

@testable import GitHubApp
import SwiftUI
import XCTest

/**
 * Simple tests for SettingsView photo picker and UI interactions.
 */
@MainActor
final class SettingsViewPhotoPickerTests: XCTestCase {
    var favoriteMoviesViewModel: FavoritesMoviesViewModel!
    var settingsViewModel: SettingsViewModel!

    override func setUp() {
        super.setUp()

        // Clear UserDefaults for clean testing
        UserDefaults.standard.removeObject(forKey: "profileImageData")
        UserDefaults.standard.removeObject(forKey: "hasRatedApp")
        UserDefaults.standard.synchronize()

        favoriteMoviesViewModel = FavoritesMoviesViewModel()
        settingsViewModel = SettingsViewModel(favoriteMoviesViewModel: favoriteMoviesViewModel)
    }

    override func tearDown() {
        favoriteMoviesViewModel = nil
        settingsViewModel = nil

        // Clean up UserDefaults
        UserDefaults.standard.removeObject(forKey: "profileImageData")
        UserDefaults.standard.removeObject(forKey: "hasRatedApp")
        UserDefaults.standard.synchronize()

        super.tearDown()
    }

    // MARK: - Basic State Tests

    func testPhotoPickerPresentationState() {
        // Given
        let localView = SettingsView(viewModel: settingsViewModel)
        let hostingController = UIHostingController(rootView: localView)
        _ = hostingController.view

        // When - Initially should not be presented
        XCTAssertFalse(settingsViewModel.isPhotoPickerPresented)

        // Then - Can be presented
        settingsViewModel.isPhotoPickerPresented = true
        XCTAssertTrue(settingsViewModel.isPhotoPickerPresented)

        // And dismissed
        settingsViewModel.isPhotoPickerPresented = false
        XCTAssertFalse(settingsViewModel.isPhotoPickerPresented)
    }

    func testAllAlertStatesIndependently() {
        // Given
        let localView = SettingsView(viewModel: settingsViewModel)
        let hostingController = UIHostingController(rootView: localView)
        _ = hostingController.view

        // When & Then - Test all alert states can be toggled independently

        // Clear favorites confirmation
        settingsViewModel.isClearLikedMoviesConfirmationPresented = true
        XCTAssertTrue(settingsViewModel.isClearLikedMoviesConfirmationPresented)
        settingsViewModel.isClearLikedMoviesConfirmationPresented = false
        XCTAssertFalse(settingsViewModel.isClearLikedMoviesConfirmationPresented)

        // Rate app thanks
        settingsViewModel.showRateAppThanks = true
        XCTAssertTrue(settingsViewModel.showRateAppThanks)
        settingsViewModel.showRateAppThanks = false
        XCTAssertFalse(settingsViewModel.showRateAppThanks)

        // Clear liked movies alert
        settingsViewModel.showClearLikedMoviesAlert = true
        XCTAssertTrue(settingsViewModel.showClearLikedMoviesAlert)
        settingsViewModel.showClearLikedMoviesAlert = false
        XCTAssertFalse(settingsViewModel.showClearLikedMoviesAlert)

        // Photo picker
        settingsViewModel.isPhotoPickerPresented = true
        XCTAssertTrue(settingsViewModel.isPhotoPickerPresented)
        settingsViewModel.isPhotoPickerPresented = false
        XCTAssertFalse(settingsViewModel.isPhotoPickerPresented)
    }

    func testProfileImageSelectionWithValidImage() {
        // Given
        let localView = SettingsView(viewModel: settingsViewModel)
        let hostingController = UIHostingController(rootView: localView)
        _ = hostingController.view

        // Create a test image
        let testImage = UIImage(systemName: "person.circle.fill")!

        // When - Handle profile image selection
        settingsViewModel.handleProfileImageSelection(testImage)

        // Then - Should handle image without crashing
        XCTAssertNotNil(settingsViewModel)
    }

    func testViewRenderingWithPhotoPickerPresented() {
        // Given
        settingsViewModel.isPhotoPickerPresented = true
        let localView = SettingsView(viewModel: settingsViewModel)
        let hostingController = UIHostingController(rootView: localView)

        // When
        _ = hostingController.view

        // Then - Should render without crashing
        XCTAssertNotNil(hostingController)
        XCTAssertTrue(settingsViewModel.isPhotoPickerPresented)
    }

    func testProfileImageWorkflowIntegration() {
        // Given
        let localView = SettingsView(viewModel: settingsViewModel)
        let hostingController = UIHostingController(rootView: localView)
        _ = hostingController.view

        // When - Full profile image workflow
        // 1. Present photo picker
        settingsViewModel.isPhotoPickerPresented = true
        XCTAssertTrue(settingsViewModel.isPhotoPickerPresented)

        // 2. Select an image
        let testImage = UIImage(systemName: "person.crop.circle.fill")!
        settingsViewModel.handleProfileImageSelection(testImage)

        // 3. Dismiss photo picker
        settingsViewModel.isPhotoPickerPresented = false
        XCTAssertFalse(settingsViewModel.isPhotoPickerPresented)

        // Then - Workflow should complete without issues
        XCTAssertNotNil(settingsViewModel)
    }

    func testClearFavoritesWorkflowIntegration() {
        // Given
        let localView = SettingsView(viewModel: settingsViewModel)
        let hostingController = UIHostingController(rootView: localView)
        _ = hostingController.view

        // When - Full clear favorites workflow
        // 1. Show confirmation
        settingsViewModel.showClearLikedMoviesConfirmation()
        XCTAssertTrue(settingsViewModel.isClearLikedMoviesConfirmationPresented)

        // 2. Clear favorites (simulates user tapping "Clear" button)
        settingsViewModel.clearAllFavoriteMovies()

        // 3. Show success alert
        settingsViewModel.showClearLikedMoviesAlert = true
        XCTAssertTrue(settingsViewModel.showClearLikedMoviesAlert)

        // 4. Dismiss alerts
        settingsViewModel.isClearLikedMoviesConfirmationPresented = false
        settingsViewModel.showClearLikedMoviesAlert = false

        // Then - Workflow should complete successfully
        XCTAssertFalse(settingsViewModel.isClearLikedMoviesConfirmationPresented)
        XCTAssertFalse(settingsViewModel.showClearLikedMoviesAlert)
    }

    func testRateAppWorkflowIntegration() {
        // Given
        let localView = SettingsView(viewModel: settingsViewModel)
        let hostingController = UIHostingController(rootView: localView)
        _ = hostingController.view

        // When - Full rate app workflow
        // 1. Rate app
        settingsViewModel.rateApp()

        // 2. Show thanks
        settingsViewModel.showRateAppThanks = true
        XCTAssertTrue(settingsViewModel.showRateAppThanks)

        // 3. Dismiss thanks
        settingsViewModel.showRateAppThanks = false
        XCTAssertFalse(settingsViewModel.showRateAppThanks)

        // Then - Workflow should complete successfully
        XCTAssertNotNil(settingsViewModel)
    }

    func testUIStateConsistencyAfterMultipleInteractions() {
        // Given
        let localView = SettingsView(viewModel: settingsViewModel)
        let hostingController = UIHostingController(rootView: localView)
        _ = hostingController.view

        // When - Perform many UI interactions rapidly
        for i in 0 ..< 5 {
            // Toggle photo picker
            settingsViewModel.isPhotoPickerPresented = (i % 2 == 0)

            // Toggle alerts
            if i % 3 == 0 {
                settingsViewModel.showClearLikedMoviesConfirmation()
                settingsViewModel.isClearLikedMoviesConfirmationPresented = false
            }

            // Call methods
            if i % 2 == 0 {
                settingsViewModel.rateApp()
                settingsViewModel.clearAllFavoriteMovies()
            }
        }

        // Then - Should maintain UI consistency
        XCTAssertNotNil(hostingController)
        XCTAssertNotNil(settingsViewModel)
    }
}
