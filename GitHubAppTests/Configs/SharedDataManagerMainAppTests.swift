//
//  SharedDataManagerMainAppTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import XCTest

final class SharedDataManagerMainAppTests: XCTestCase {
    // MARK: - Properties

    private var sharedDataManager: SharedDataManager!
    private var testMovies: [SharedMovie]!

    // MARK: - Setup and Teardown

    override func setUp() {
        super.setUp()
        sharedDataManager = SharedDataManager.shared

        testMovies = [
            SharedMovie(
                id: 1,
                title: "Test Movie 1",
                overview: "This is the first test movie",
                posterPath: "/test1.jpg"
            ),
            SharedMovie(
                id: 2,
                title: "Test Movie 2",
                overview: "This is the second test movie",
                posterPath: "/test2.jpg"
            ),
            SharedMovie(
                id: 3,
                title: "Test Movie 3",
                overview: "This is the third test movie",
                posterPath: nil
            ),
        ]

        // Clear any existing data
        sharedDataManager.clearData()
    }

    override func tearDown() {
        sharedDataManager.clearData()
        sharedDataManager = nil
        testMovies = nil
        super.tearDown()
    }

    // MARK: - Save and Retrieve Tests

    func testSaveAndRetrieveUpcomingMovies() {
        // When
        sharedDataManager.saveUpcomingMovies(testMovies)
        let retrievedMovies = sharedDataManager.getUpcomingMovies()

        // Then
        XCTAssertEqual(retrievedMovies.count, 3)
        XCTAssertEqual(retrievedMovies[0].id, 1)
        XCTAssertEqual(retrievedMovies[0].title, "Test Movie 1")
        XCTAssertEqual(retrievedMovies[1].id, 2)
        XCTAssertEqual(retrievedMovies[2].id, 3)
        XCTAssertNil(retrievedMovies[2].posterPath)
    }

    func testSaveEmptyMoviesArray() {
        // Given
        let emptyMovies: [SharedMovie] = []

        // When
        sharedDataManager.saveUpcomingMovies(emptyMovies)
        let retrievedMovies = sharedDataManager.getUpcomingMovies()

        // Then
        XCTAssertTrue(retrievedMovies.isEmpty)
    }

    func testRetrieveMoviesWhenNoneExists() {
        // When
        let retrievedMovies = sharedDataManager.getUpcomingMovies()

        // Then
        XCTAssertTrue(retrievedMovies.isEmpty)
    }

    func testOverwriteExistingMovies() {
        // Given
        sharedDataManager.saveUpcomingMovies(testMovies)
        let newMovies = [
            SharedMovie(id: 4, title: "New Movie", overview: "New overview", posterPath: "/new.jpg"),
        ]

        // When
        sharedDataManager.saveUpcomingMovies(newMovies)
        let retrievedMovies = sharedDataManager.getUpcomingMovies()

        // Then
        XCTAssertEqual(retrievedMovies.count, 1)
        XCTAssertEqual(retrievedMovies[0].id, 4)
        XCTAssertEqual(retrievedMovies[0].title, "New Movie")
    }

    // MARK: - Data Freshness Tests

    func testIsDataFreshAfterSaving() {
        // When
        sharedDataManager.saveUpcomingMovies(testMovies)
        let isFresh = sharedDataManager.isDataFresh()

        // Then
        XCTAssertTrue(isFresh)
    }

    func testIsDataFreshWhenNoDataExists() {
        // When
        let isFresh = sharedDataManager.isDataFresh()

        // Then
        XCTAssertFalse(isFresh)
    }

    func testIsDataFreshWithOldData() {
        // Given
        sharedDataManager.saveUpcomingMovies(testMovies)

        // Simulate old data by directly setting an old timestamp
        let userDefaults: UserDefaults = if let appGroupDefaults = UserDefaults(suiteName: "group.com.bruno.GitHubApp") {
            appGroupDefaults
        } else {
            UserDefaults.standard
        }

        let threeHoursAgo = Calendar.current.date(byAdding: .hour, value: -3, to: Date()) ?? Date()
        userDefaults.set(threeHoursAgo, forKey: "shared_last_update")

        // When
        let isFresh = sharedDataManager.isDataFresh()

        // Then
        XCTAssertFalse(isFresh)
    }

    // MARK: - Clear Data Tests

    func testClearData() {
        // Given
        sharedDataManager.saveUpcomingMovies(testMovies)
        XCTAssertFalse(sharedDataManager.getUpcomingMovies().isEmpty)
        XCTAssertTrue(sharedDataManager.isDataFresh())

        // When
        sharedDataManager.clearData()

        // Then
        XCTAssertTrue(sharedDataManager.getUpcomingMovies().isEmpty)
        XCTAssertFalse(sharedDataManager.isDataFresh())
    }

    func testRetrieveMoviesWithCorruptedUserDefaults() {
        // Given - Manually set invalid data in UserDefaults
        let userDefaults: UserDefaults = if let appGroupDefaults = UserDefaults(suiteName: "group.com.bruno.GitHubApp") {
            appGroupDefaults
        } else {
            UserDefaults.standard
        }

        // Set invalid JSON data
        let invalidData = "invalid json data".data(using: .utf8)!
        userDefaults.set(invalidData, forKey: "shared_upcoming_movies")

        // When
        let retrievedMovies = sharedDataManager.getUpcomingMovies()

        // Then - Should return empty array when decoding fails
        XCTAssertTrue(retrievedMovies.isEmpty)
    }
}
