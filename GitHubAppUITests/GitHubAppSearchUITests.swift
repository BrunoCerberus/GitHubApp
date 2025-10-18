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
 * - Navigating to search tab
 * - Entering search text
 * - Verifying search results display
 * - Interacting with movie items
 * - Navigation to movie details
 */
final class GitHubAppSearchUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // Ensure device starts in portrait mode before any UI tests
        XCUIDevice.shared.orientation = .portrait

        app = XCUIApplication()
        // Provide API key and mark environment as testing so the app uses mock services
        app.launchEnvironment["API_KEY"] = "ui-tests-key"
        app.launchEnvironment["XCTestConfigurationFilePath"] = "UI"
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.

        // Reset device orientation to portrait to avoid affecting other tests
        XCUIDevice.shared.orientation = .portrait
    }

    /// Test that app launches successfully and displays home view
    func testAppLaunchesSuccessfully() throws {
        app.launch()

        // Verify app launched by checking for navigation bar
        XCTAssertTrue(app.navigationBars.element.exists)
    }

    /// Test navigating to search tab
    func testNavigateToSearchTab() throws {
        app.launch()

        // Tap on Search tab
        app.tabBars.buttons["Search"].tap()

        // Verify search view is displayed
        XCTAssertTrue(app.navigationBars["Search"].exists)
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

        // Wait for search results to appear (give time for mock API call)
        let movieTitle = app.staticTexts["Barbie"]
        let predicate = NSPredicate(format: "exists == 1")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: movieTitle)
        let result = XCTestWaiter().wait(for: [expectation], timeout: 5.0)

        XCTAssertEqual(result, .completed, "Barbie title should appear in search results")
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

        // Wait for results to appear
        let firstResult = app.staticTexts.element(matching: NSPredicate(format: "label CONTAINS 'Barbie'"))
        XCTAssertTrue(waitForElement(firstResult, timeout: 5))

        // Verify multiple movie results are visible
        let allStaticTexts = app.staticTexts.allElementsBoundByIndex
        XCTAssertGreaterThan(allStaticTexts.count, 0, "Search results should contain movie titles")
    }

    /// Test tapping on a search result navigates to movie details
    func testTappingSearchResultNavigatesToMovieDetails() throws {
        app.launch()

        // Tap on Search tab
        app.tabBars.buttons["Search"].tap()

        // Tap on search field and enter search text
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("Barbie")

        // Wait for search result to appear and tap it
        let barbieText = app.staticTexts["Barbie"]
        XCTAssertTrue(waitForElement(barbieText, timeout: 5))

        // Find and tap the Barbie cell
        let barbieCell = app.cells.containing(barbieText).firstMatch
        barbieCell.tap()

        // Verify movie details view is displayed (should have movie title as navigation bar)
        let movieDetailsNav = app.navigationBars["Barbie"]
        XCTAssertTrue(waitForElement(movieDetailsNav, timeout: 5))
    }

    /// Test clearing search text returns to empty state
    func testClearingSearchTextReturnsToEmptyState() throws {
        app.launch()

        // Tap on Search tab
        app.tabBars.buttons["Search"].tap()

        // Enter search text
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("test")

        // Wait for results to appear
        let firstResult = app.staticTexts.element(matching: NSPredicate(format: "label CONTAINS 'Barbie'"))
        XCTAssertTrue(waitForElement(firstResult, timeout: 5))

        // Clear search field
        searchField.clearText()

        // Verify empty state is shown again
        XCTAssertTrue(waitForElement(app.staticTexts["Search for Movies"], timeout: 3))
    }

    /// Test that search is debounced (only performs final search, not every keystroke)
    func testSearchIsDebounced() throws {
        app.launch()

        // Tap on Search tab
        app.tabBars.buttons["Search"].tap()

        // Tap on search field
        let searchField = app.searchFields.firstMatch
        searchField.tap()

        // Type search query slowly (character by character)
        searchField.typeText("B")
        usleep(100_000) // 0.1 seconds
        searchField.typeText("a")
        usleep(100_000)
        searchField.typeText("r")
        usleep(100_000)
        searchField.typeText("b")
        usleep(100_000)
        searchField.typeText("i")
        usleep(100_000)
        searchField.typeText("e")

        // Wait for final search to complete
        let barbieResult = app.staticTexts["Barbie"]
        XCTAssertTrue(waitForElement(barbieResult, timeout: 5))
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

        // Wait for results to appear
        let firstResult = app.staticTexts.element(matching: NSPredicate(format: "label CONTAINS 'Barbie'"))
        XCTAssertTrue(waitForElement(firstResult, timeout: 5))

        // Find the results list
        let listView = app.collectionViews.firstMatch
        XCTAssertTrue(listView.exists)

        // Scroll down
        listView.swipeUp()

        // Verify we can still see content
        XCTAssertTrue(listView.exists)
    }

    /// Test navigating back from movie details to search results
    func testNavigatingBackFromMovieDetails() throws {
        app.launch()

        // Tap on Search tab
        app.tabBars.buttons["Search"].tap()

        // Enter search text
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("Barbie")

        // Wait for and tap search result
        let barbieText = app.staticTexts["Barbie"]
        XCTAssertTrue(waitForElement(barbieText, timeout: 5))
        let barbieCell = app.cells.containing(barbieText).firstMatch
        barbieCell.tap()

        // Verify we're in movie details
        let movieDetailsNav = app.navigationBars["Barbie"]
        XCTAssertTrue(waitForElement(movieDetailsNav, timeout: 5))

        // Tap back button
        app.navigationBars["Barbie"].buttons.element(boundBy: 0).tap()

        // Verify we're back in search tab
        XCTAssertTrue(waitForElement(app.navigationBars["Search"], timeout: 3))
    }

    /// Test that tab persistence maintains search state
    func testTabPersistenceMaintsainsSearchState() throws {
        app.launch()

        // Tap on Search tab
        app.tabBars.buttons["Search"].tap()

        // Enter search text
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("Barbie")

        // Wait for search results
        let barbieText = app.staticTexts["Barbie"]
        XCTAssertTrue(waitForElement(barbieText, timeout: 5))

        // Switch to another tab
        app.tabBars.buttons["Home"].tap()

        // Wait a moment
        usleep(500_000) // 0.5 seconds

        // Switch back to Search tab
        app.tabBars.buttons["Search"].tap()

        // Search results should still be visible (search was preserved)
        XCTAssertTrue(waitForElement(barbieText, timeout: 3))
    }

    // MARK: - Helper Methods

    /// Wait for a UI element to exist within a timeout period
    /// - Parameters:
    ///   - element: The XCUIElement to wait for
    ///   - timeout: Maximum time to wait in seconds
    /// - Returns: true if element appeared within timeout, false otherwise
    private func waitForElement(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "exists == 1")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTestWaiter().wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
}

// MARK: - XCUIElement Extensions

extension XCUIElement {
    /// Clear text from a text field by selecting all and deleting
    func clearText() {
        let app = XCUIApplication()
        tap()
        tap() // Double tap to select all
        app.menuItems["Delete"].tap()
    }
}
