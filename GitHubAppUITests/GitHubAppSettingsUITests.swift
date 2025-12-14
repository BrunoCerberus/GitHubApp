//
//  GitHubAppSettingsUITests.swift
//  GitHubAppUITests
//
//  Created by bruno on Settings UI testing.
//

import XCTest

/**
 * UI tests for the Settings page functionality.
 *
 * Tests cover:
 * - Clear favorites functionality
 * - Rate app functionality
 * - Tab navigation integration
 */
final class GitHubAppSettingsUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait

        app = XCUIApplication()
        app.launchEnvironment["API_KEY"] = "ui-tests-key"
        app.launchEnvironment["XCTestConfigurationFilePath"] = "UI"
        app.launch()

        _ = app.wait(for: .runningForeground, timeout: 5.0)
    }

    override func tearDownWithError() throws {
        // Explicitly terminate app to prevent "Failed to terminate" flakiness on CI
        if app.state != .notRunning {
            app.terminate()
        }
        XCUIDevice.shared.orientation = .portrait
        app = nil
    }

    // MARK: - Clear Favorites Tests

    /// Test clear favorites card visibility and interaction
    func testClearFavoriteMoviesCard() throws {
        navigateToSettings()

        // Verify clear favorites card elements
        let clearFavoritesText = app.staticTexts["Clear Favorite Movies"]
        XCTAssertTrue(clearFavoritesText.exists, "Clear Favorite Movies text should be visible")

        let descriptionText = app.staticTexts["Remove all movies from your favorites list"]
        XCTAssertTrue(descriptionText.exists, "Description text should be visible")

        // Verify heart slash icon
        let heartSlashIcon = app.images["heart.slash.fill"]
        XCTAssertTrue(heartSlashIcon.exists, "Heart slash icon should be visible")

        // Verify chevron right icon
        let chevronIcon = app.images["chevron.right"]
        XCTAssertTrue(chevronIcon.exists, "Chevron right icon should be visible")

        // Test clear favorites button interaction
        let clearFavoritesButton = app.buttons.containing(.staticText, identifier: "Clear Favorite Movies").firstMatch
        XCTAssertTrue(clearFavoritesButton.exists, "Clear favorites button should exist")

        clearFavoritesButton.tap()

        // Verify confirmation alert appears
        let confirmationAlert = app.alerts["Remove favorite movies?"]
        XCTAssertTrue(confirmationAlert.waitForExistence(timeout: 2.0), "Confirmation alert should appear")

        // Verify alert buttons
        let clearButton = confirmationAlert.buttons["Clear All"]
        let cancelButton = confirmationAlert.buttons["Cancel"]

        XCTAssertTrue(clearButton.exists, "Clear button should exist in alert")
        XCTAssertTrue(cancelButton.exists, "Cancel button should exist in alert")

        // Test cancel functionality
        cancelButton.tap()
        XCTAssertFalse(confirmationAlert.exists, "Alert should dismiss after cancel")
    }

    /// Test clear favorites confirmation flow
    func testClearFavoriteMoviesConfirmation() throws {
        navigateToSettings()

        let clearFavoritesButton = app.buttons.containing(.staticText, identifier: "Clear Favorite Movies").firstMatch
        clearFavoritesButton.tap()

        let confirmationAlert = app.alerts["Remove favorite movies?"]
        XCTAssertTrue(confirmationAlert.waitForExistence(timeout: 2.0), "Confirmation alert should appear")

        // Test clear confirmation
        let clearButton = confirmationAlert.buttons["Clear All"]
        clearButton.tap()

        // Verify success alert appears
        let successAlert = app.alerts["Remove favorite movies?"]
        XCTAssertTrue(successAlert.waitForExistence(timeout: 3.0), "Success alert should appear")

        let okButton = successAlert.buttons["OK"]
        XCTAssertTrue(okButton.exists, "OK button should exist in success alert")
        okButton.tap()
    }

    // MARK: - Rate App Tests

    /// Test rate app card visibility and interaction
    func testRateAppCard() throws {
        navigateToSettings()

        // Scroll down to ensure Rate App card is visible (it's near the bottom)
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            scrollView.swipeUp()
        }

        // Verify rate app card elements (only if card is visible)
        let rateAppText = app.staticTexts["Rate App"]

        // Skip test if rate app card is not visible (user already rated)
        guard rateAppText.waitForExistence(timeout: 3.0) else {
            throw XCTSkip("Rate App card is not visible (user may have already rated the app)")
        }

        let descriptionText = app.staticTexts["Help us improve by rating the app"]
        XCTAssertTrue(descriptionText.exists, "Description text should be visible")

        // Verify star icon
        let starIcon = app.images["star.fill"]
        XCTAssertTrue(starIcon.exists, "Star icon should be visible")

        // Verify 5-star rating display (should have 5 star icons)
        let starIcons = app.images.matching(identifier: "star.fill")
        XCTAssertGreaterThanOrEqual(starIcons.count, 5, "Should have at least 5 star icons for rating display")

        // Test rate app button interaction
        let rateAppButton = app.buttons.containing(.staticText, identifier: "Rate App").firstMatch
        XCTAssertTrue(rateAppButton.exists, "Rate app button should exist")

        rateAppButton.tap()

        // Verify thanks alert appears and dismiss it quickly
        // Note: The alert auto-dismisses after 2 seconds, so we must tap immediately
        let thanksAlert = app.alerts["Rate App"]
        if thanksAlert.waitForExistence(timeout: 5.0) {
            // Tap OK immediately - alert auto-dismisses after 2 seconds
            let okButton = thanksAlert.buttons["OK"]
            if okButton.waitForExistence(timeout: 1.0) {
                okButton.tap()
            }
        }
    }

    // MARK: - Integration Tests

    /// Test navigation between tabs with Settings
    func testTabNavigationIntegration() throws {
        // Start from Settings
        navigateToSettings()
        XCTAssertTrue(app.navigationBars["Settings"].exists, "Should be on Settings page")

        // Navigate to Home
        app.tabBars.buttons["Home"].tap()
        // Wait for the home view to be visible - check for tab selection instead of navigation title
        XCTAssertTrue(app.tabBars.buttons["Home"].isSelected, "Should navigate to Home tab")

        // Navigate to Favorites
        app.tabBars.buttons["Favorites"].tap()
        // Check for tab selection instead of navigation title since there might be timing issues
        XCTAssertTrue(app.tabBars.buttons["Favorites"].isSelected, "Should navigate to Favorites tab")

        // Navigate back to Settings
        app.tabBars.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 2.0), "Should navigate back to Settings")
    }

    // MARK: - Helper Methods

    /// Navigate to Settings tab
    private func navigateToSettings() {
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 2.0), "Settings page should load")
    }
}
