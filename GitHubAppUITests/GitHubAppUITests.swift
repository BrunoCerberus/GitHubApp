//
//  GitHubAppUITests.swift
//  GitHubAppUITests
//
//  Created by bruno on 28/05/23.
//

import XCTest

/**
 * Basic UI smoke tests for application launch and performance.
 */
final class GitHubAppUITests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // Ensure device starts in portrait mode before any UI tests
        XCUIDevice.shared.orientation = .portrait
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.

        // Reset device orientation to portrait to avoid affecting other tests
        XCUIDevice.shared.orientation = .portrait
    }

    /// Launches the app to verify it starts without crashing
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        // Provide API key and mark environment as testing so the app uses mock services
        app.launchEnvironment["API_KEY"] = "ui-tests-key"
        app.launchEnvironment["XCTestConfigurationFilePath"] = "UI"
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    /// Navigate to Favorites tab to exercise FavoritesMoviesView
    func testNavigateToFavoritesTab() throws {
        let app = XCUIApplication()
        app.launchEnvironment["API_KEY"] = "ui-tests-key"
        app.launchEnvironment["XCTestConfigurationFilePath"] = "UI"
        app.launch()

        // Navigate to Favorites tab
        let favoritesTab = app.tabBars.buttons["Favorites"]
        XCTAssertTrue(favoritesTab.exists, "Favorites tab should exist")
        favoritesTab.tap()

        // Wait a moment for the view to load
        Thread.sleep(forTimeInterval: 1.0)

        // Verify we're on the Favorites tab - just check that tapping succeeded without crashing
        // The favorites list may be empty if no movies have been favorited yet
        XCTAssertTrue(favoritesTab.isSelected, "Favorites tab should be selected after tapping")
    }

    /// Measures cold launch performance for the app
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                let app = XCUIApplication()
                app.launchEnvironment["API_KEY"] = "ui-tests-key"
                app.launchEnvironment["XCTestConfigurationFilePath"] = "UI"
                app.launch()
            }
        }
    }
}
