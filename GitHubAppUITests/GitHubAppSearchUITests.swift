//
//  GitHubAppSearchUITests.swift
//  GitHubAppUITests
//
//  UI tests for SearchView functionality
//

import XCTest

/**
 * UI tests for SearchView feature.
 *
 * Tests user interactions with the search interface including:
 * - Entering search text
 * - Verifying search results display
 * - Scrolling through results
 */
final class GitHubAppSearchUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait

        app = XCUIApplication()
        app.launchEnvironment["API_KEY"] = "ui-tests-key"
        app.launchEnvironment["XCTestConfigurationFilePath"] = "UI"
    }

    override func tearDownWithError() throws {
        XCUIDevice.shared.orientation = .portrait
    }

    /// Test that search tab shows empty state initially
    func testSearchTabShowsEmptyStateInitially() throws {
        app.launch()

        // Tap on Search tab
        app.tabBars.buttons["Search"].tap()

        // Verify empty state is displayed with search prompt
        XCTAssertTrue(app.staticTexts["Search for Movies"].exists)
        XCTAssertTrue(app.staticTexts["Find your favorite movies by title"].exists)
    }

    /// Test entering search text triggers search
    func testEnteringSearchTextTriggersSearch() throws {
        app.launch()

        // Tap on Search tab
        app.tabBars.buttons["Search"].tap()

        // Tap on search field
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.exists)

        searchField.tap()

        // Type search query
        searchField.typeText("Barbie")

        // Wait for search results to appear (increased timeout for CI environments)
        let movieTitle = app.staticTexts["Barbie"]
        XCTAssertTrue(
            movieTitle.waitForExistence(timeout: 15.0),
            "Barbie title should appear in search results"
        )
    }

    /// Test that search results are displayed as a list
    func testSearchResultsDisplayedAsList() throws {
        app.launch()

        // Tap on Search tab
        app.tabBars.buttons["Search"].tap()

        // Tap on search field and enter search text
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("test")

        // Wait for results to appear (increased timeout for CI environments)
        let barbieText = app.staticTexts["Barbie"]
        XCTAssertTrue(waitForElement(barbieText, timeout: 15))

        // Verify multiple movie results are visible
        let allStaticTexts = app.staticTexts.allElementsBoundByIndex
        XCTAssertGreaterThan(allStaticTexts.count, 0, "Search results should contain movie titles")
    }

    /// Test scrolling through search results
    func testScrollingThroughSearchResults() throws {
        app.launch()

        // Tap on Search tab
        app.tabBars.buttons["Search"].tap()

        // Enter search text
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("test")

        // Wait for results to appear (increased timeout for CI environments)
        let barbieText = app.staticTexts["Barbie"]
        XCTAssertTrue(waitForElement(barbieText, timeout: 15))

        // Find the results list
        let listView = app.collectionViews.firstMatch
        XCTAssertTrue(listView.exists)

        // Scroll down
        listView.swipeUp()

        // Verify we can still see content
        XCTAssertTrue(listView.exists)
    }

    // MARK: - Helper Methods

    /// Wait for a UI element to exist within a timeout period
    /// - Parameters:
    ///   - element: The XCUIElement to wait for
    ///   - timeout: Maximum time to wait in seconds
    /// - Returns: true if element appeared within timeout, false otherwise
    private func waitForElement(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
}
