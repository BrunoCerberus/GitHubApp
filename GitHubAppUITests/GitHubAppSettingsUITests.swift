//
//  GitHubAppSettingsUITests.swift
//  GitHubAppUITests
//
//  Created by bruno on Settings UI testing.
//

import XCTest

/**
 * Comprehensive UI tests for the Settings page functionality.
 *
 * Tests cover:
 * - Navigation to Settings page
 * - Settings page UI elements visibility
 * - Profile image picker interaction
 * - Clear favorites functionality
 * - Rate app functionality
 * - Alert dialogs and confirmations
 * - Accessibility identifiers
 */
final class GitHubAppSettingsUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchEnvironment["API_KEY"] = "ui-tests-key"
        app.launchEnvironment["XCTestConfigurationFilePath"] = "UI"
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Navigation Tests

    /// Test navigation to Settings tab and verify basic UI elements
    func testNavigateToSettingsTab() throws {
        // Navigate to Settings tab
        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.exists, "Settings tab should exist")
        settingsTab.tap()

        // Verify Settings page is displayed
        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 2.0), "Settings navigation title should be visible")
    }

    // MARK: - Profile Section Tests

    /// Test profile image section visibility and interaction
    func testProfileImageSection() throws {
        navigateToSettings()

        // Verify profile image section elements
        let profileImageText = app.staticTexts["Profile Image"]
        XCTAssertTrue(profileImageText.exists, "Profile Image text should be visible")

        let tapToChangeText = app.staticTexts["Tap to change your profile picture"]
        XCTAssertTrue(tapToChangeText.exists, "Tap to change text should be visible")

        // Test profile image button exists and is tappable
        let profileImageButton = app.buttons.containing(.image, identifier: "person.fill").firstMatch
        XCTAssertTrue(profileImageButton.exists, "Profile image button should exist")

        // Note: We don't actually tap to avoid triggering the photo picker in UI tests
        // as it would require system permissions and real photo access
    }

    // MARK: - App Version Card Tests

    /// Test app version card display and information
    func testAppVersionCard() throws {
        navigateToSettings()

        // Verify app version card elements
        let appVersionText = app.staticTexts["App Version"]
        XCTAssertTrue(appVersionText.exists, "App Version text should be visible")

        let buildText = app.staticTexts["Build"]
        XCTAssertTrue(buildText.exists, "Build text should be visible")

        // Verify version and build numbers are displayed (they should be non-empty)
        let versionElements = app.staticTexts.matching(NSPredicate(format: "label MATCHES '^\\d+\\.\\d+\\.\\d+$'"))
        let buildElements = app.staticTexts.matching(NSPredicate(format: "label MATCHES '^\\d+$'"))

        XCTAssertGreaterThan(versionElements.count, 0, "Version number should be displayed")
        XCTAssertGreaterThan(buildElements.count, 0, "Build number should be displayed")

        // Verify info circle icon
        let infoIcon = app.images["info.circle.fill"]
        XCTAssertTrue(infoIcon.exists, "Info circle icon should be visible")
    }

    // MARK: - Clear Favorites Tests

    /// Test clear favorites card visibility and interaction
    func testClearFavoriteMoviesCard() throws {
        navigateToSettings()

        // Verify clear favorites card elements
        let clearFavoritesText = app.staticTexts["Clear Favorite Movies?"]
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
        let confirmationAlert = app.alerts["Clear Favorite Movies?"]
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

        let clearFavoritesButton = app.buttons.containing(.staticText, identifier: "Clear Favorite Movies?").firstMatch
        clearFavoritesButton.tap()

        let confirmationAlert = app.alerts["Clear Favorite Movies?"]
        XCTAssertTrue(confirmationAlert.waitForExistence(timeout: 2.0), "Confirmation alert should appear")

        // Test clear confirmation
        let clearButton = confirmationAlert.buttons["Clear All"]
        clearButton.tap()

        // Verify success alert appears
        let successAlert = app.alerts["Clear Favorite Movies?"]
        XCTAssertTrue(successAlert.waitForExistence(timeout: 3.0), "Success alert should appear")

        let okButton = successAlert.buttons["OK"]
        XCTAssertTrue(okButton.exists, "OK button should exist in success alert")
        okButton.tap()
    }

    // MARK: - Rate App Tests

    /// Test rate app card visibility and interaction
    func testRateAppCard() throws {
        navigateToSettings()

        // Verify rate app card elements
        let rateAppText = app.staticTexts["Rate App"]
        XCTAssertTrue(rateAppText.exists, "Rate App text should be visible")

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

        // Verify thanks alert appears
        let thanksAlert = app.alerts["Rate App"]
        XCTAssertTrue(thanksAlert.waitForExistence(timeout: 2.0), "Thanks alert should appear")

        let okButton = thanksAlert.buttons["OK"]
        XCTAssertTrue(okButton.exists, "OK button should exist in thanks alert")
        okButton.tap()
    }

    /// Test that rate app card disappears after rating
    func testRateAppCardDisappearsAfterRating() throws {
        navigateToSettings()

        let rateAppButton = app.buttons.containing(.staticText, identifier: "Rate App").firstMatch
        XCTAssertTrue(rateAppButton.exists, "Rate app button should initially exist")

        // Rate the app
        rateAppButton.tap()
        let thanksAlert = app.alerts["Rate App"]
        thanksAlert.buttons["OK"].tap()

        // Navigate away and back to refresh the view
        app.tabBars.buttons["Home"].tap()
        app.tabBars.buttons["Settings"].tap()

        // Verify rate app card is no longer visible
        let rateAppButtonAfter = app.buttons.containing(.staticText, identifier: "Rate App").firstMatch
        XCTAssertFalse(rateAppButtonAfter.exists, "Rate app button should disappear after rating")
    }

    // MARK: - Scroll and Layout Tests

    /// Test scrolling functionality in Settings view
    func testSettingsViewScrolling() throws {
        navigateToSettings()

        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.exists, "Scroll view should exist")

        // Verify we can scroll down
        scrollView.swipeUp()

        // Verify we can scroll back up
        scrollView.swipeDown()

        // Verify all main elements are still accessible after scrolling
        let profileImageText = app.staticTexts["Profile Image"]
        let appVersionText = app.staticTexts["App Version"]
        let clearFavoritesText = app.staticTexts["Clear Favorite Movies"]

        XCTAssertTrue(profileImageText.exists, "Profile Image should be visible after scrolling")
        XCTAssertTrue(appVersionText.exists, "App Version should be visible after scrolling")
        XCTAssertTrue(clearFavoritesText.exists, "Clear Favorites should be visible after scrolling")
    }

    // MARK: - Accessibility Tests

    /// Test accessibility labels and elements
    func testAccessibilityElements() throws {
        navigateToSettings()

        // Verify navigation title is accessible
        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(settingsTitle.isHittable, "Settings title should be accessible")

        // Verify main interactive elements are accessible
        let profileImageButton = app.buttons.containing(.image, identifier: "person.fill").firstMatch
        XCTAssertTrue(profileImageButton.isHittable, "Profile image button should be accessible")

        let clearFavoritesButton = app.buttons.containing(.staticText, identifier: "Clear Favorite Movies?").firstMatch
        XCTAssertTrue(clearFavoritesButton.isHittable, "Clear favorites button should be accessible")

        let rateAppButton = app.buttons.containing(.staticText, identifier: "Rate App").firstMatch
        if rateAppButton.exists {
            XCTAssertTrue(rateAppButton.isHittable, "Rate app button should be accessible when visible")
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
        XCTAssertTrue(app.navigationBars["Movies"].waitForExistence(timeout: 2.0), "Should navigate to Home")

        // Navigate to Favorites
        app.tabBars.buttons["Favorites"].tap()
        XCTAssertTrue(app.navigationBars["Favorites"].waitForExistence(timeout: 2.0), "Should navigate to Favorites")

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
