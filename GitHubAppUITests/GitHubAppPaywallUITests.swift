//
//  GitHubAppPaywallUITests.swift
//  GitHubAppUITests
//
//  Created by bruno on paywall functionality.
//

import XCTest

/**
 * UI tests for the Paywall functionality.
 *
 * Tests cover:
 * - Navigation to Paywall from Settings
 * - Premium card visibility
 * - Dismiss functionality
 * - Presentation cycle
 */
final class GitHubAppPaywallUITests: XCTestCase {
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
        app = nil
        XCUIDevice.shared.orientation = .portrait
    }

    // MARK: - Navigation Tests

    /// Test navigation to Paywall from Settings premium card
    func testNavigateToPaywallFromSettings() throws {
        // Navigate to Settings tab
        navigateToSettings()

        // Find and tap the premium card
        let premiumCard = app.buttons.containing(.staticText, identifier: "Go Premium").firstMatch

        // Skip test if premium card is not visible (user may already be premium)
        guard premiumCard.exists else {
            throw XCTSkip("Premium card is not visible (user may already be premium)")
        }

        premiumCard.tap()

        // Verify Paywall is presented
        // The paywall uses SubscriptionStoreView which has specific elements
        // We check for the dismiss button which we added
        let dismissButton = app.buttons.matching(identifier: "xmark.circle.fill").firstMatch
        XCTAssertTrue(dismissButton.waitForExistence(timeout: 3.0), "Paywall dismiss button should be visible")
    }

    // MARK: - Paywall UI Elements Tests

    /// Test premium card visibility in Settings
    func testPremiumCardInSettings() throws {
        navigateToSettings()

        // Check for premium-related text
        let goPremiumText = app.staticTexts["Go Premium"]
        let premiumActiveText = app.staticTexts["Premium Active"]

        // Either "Go Premium" or "Premium Active" should be visible
        let hasPremiumCard = goPremiumText.exists || premiumActiveText.exists
        XCTAssertTrue(hasPremiumCard, "Premium card should be visible in Settings")

        if goPremiumText.exists {
            // Verify unlock features text
            let unlockFeaturesText = app.staticTexts["Unlock all premium features"]
            XCTAssertTrue(unlockFeaturesText.exists, "Unlock features description should be visible")

            // Verify crown icon
            let crownIcon = app.images["crown"]
            XCTAssertTrue(crownIcon.exists, "Crown icon should be visible for non-premium")
        }

        if premiumActiveText.exists {
            // Verify full access text
            let fullAccessText = app.staticTexts["You have full access to all features"]
            XCTAssertTrue(fullAccessText.exists, "Full access description should be visible for premium users")

            // Verify filled crown icon
            let crownFilledIcon = app.images["crown.fill"]
            XCTAssertTrue(crownFilledIcon.exists, "Filled crown icon should be visible for premium users")

            // Verify checkmark icon
            let checkmarkIcon = app.images["checkmark.circle.fill"]
            XCTAssertTrue(checkmarkIcon.exists, "Checkmark icon should be visible for premium users")
        }
    }

    // MARK: - Dismiss Tests

    /// Test paywall dismiss functionality
    func testPaywallDismiss() throws {
        navigateToSettings()

        let premiumCard = app.buttons.containing(.staticText, identifier: "Go Premium").firstMatch

        // Skip test if premium card is not visible
        guard premiumCard.exists else {
            throw XCTSkip("Premium card is not visible")
        }

        premiumCard.tap()

        // Wait for paywall to appear
        let dismissButton = app.buttons.matching(identifier: "xmark.circle.fill").firstMatch
        XCTAssertTrue(dismissButton.waitForExistence(timeout: 3.0), "Paywall dismiss button should be visible")

        // Tap dismiss button
        dismissButton.tap()

        // Verify paywall is dismissed
        XCTAssertTrue(dismissButton.waitForNonExistence(timeout: 2.0), "Paywall should be dismissed")

        // Verify we're back in Settings
        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 2.0), "Should return to Settings after dismiss")
    }

    // MARK: - Integration Tests

    /// Test paywall presentation and dismissal cycle
    func testPaywallPresentationCycle() throws {
        navigateToSettings()

        let premiumCard = app.buttons.containing(.staticText, identifier: "Go Premium").firstMatch

        // Skip test if premium card is not visible
        guard premiumCard.exists else {
            throw XCTSkip("Premium card is not visible")
        }

        // First presentation
        premiumCard.tap()
        var dismissButton = app.buttons.matching(identifier: "xmark.circle.fill").firstMatch
        XCTAssertTrue(dismissButton.waitForExistence(timeout: 3.0), "First paywall presentation should work")
        dismissButton.tap()
        XCTAssertTrue(dismissButton.waitForNonExistence(timeout: 2.0), "First dismissal should work")

        // Wait for Settings to be fully visible again
        sleep(1)

        // Second presentation
        premiumCard.tap()
        dismissButton = app.buttons.matching(identifier: "xmark.circle.fill").firstMatch
        XCTAssertTrue(dismissButton.waitForExistence(timeout: 3.0), "Second paywall presentation should work")
        dismissButton.tap()
        XCTAssertTrue(dismissButton.waitForNonExistence(timeout: 2.0), "Second dismissal should work")
    }

    /// Test navigation between tabs with paywall
    func testTabNavigationWithPaywall() throws {
        // Start from Settings
        navigateToSettings()
        XCTAssertTrue(app.navigationBars["Settings"].exists, "Should be on Settings page")

        // Navigate to Home
        app.tabBars.buttons["Home"].tap()
        XCTAssertTrue(app.tabBars.buttons["Home"].isSelected, "Should navigate to Home tab")

        // Navigate back to Settings
        app.tabBars.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 2.0), "Should navigate back to Settings")

        // Verify premium card is still visible
        let premiumCard = app.buttons.containing(.staticText, identifier: "Go Premium").firstMatch
        let premiumActive = app.staticTexts["Premium Active"]
        let hasPremiumCard = premiumCard.exists || premiumActive.exists
        XCTAssertTrue(hasPremiumCard, "Premium card should still be visible after navigation")
    }

    // MARK: - Helper Methods

    /// Navigate to Settings tab
    private func navigateToSettings() {
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 2.0), "Settings page should load")
    }
}

// MARK: - XCUIElement Extension

private extension XCUIElement {
    /// Wait for the element to no longer exist
    func waitForNonExistence(timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
}
