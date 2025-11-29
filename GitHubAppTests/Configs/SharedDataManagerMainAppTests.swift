//
//  SharedDataManagerMainAppTests.swift
//  GitHubAppTests
//

import Foundation
@testable import GitHubApp
import Testing

/**
 * Note: Tests run serially (.serialized) because they share UserDefaults storage
 * with WidgetDataManagerTests and SharedDataManagerTests.
 */
@Suite(.serialized)
@MainActor
struct SharedDataManagerMainAppTests {
    private func createTestComponents() -> (SharedDataManager, [SharedMovie]) {
        let sharedDataManager = SharedDataManager.shared

        let testMovies = [
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

        return (sharedDataManager, testMovies)
    }

    private func cleanupTest(_ sharedDataManager: SharedDataManager) {
        sharedDataManager.clearData()
    }

    // MARK: - Save and Retrieve Tests

    @Test("Save and retrieve upcoming movies")
    func saveAndRetrieveUpcomingMovies() {
        // Given
        let (sharedDataManager, testMovies) = createTestComponents()
        defer { cleanupTest(sharedDataManager) }

        // When
        sharedDataManager.saveUpcomingMovies(testMovies)
        let retrievedMovies = sharedDataManager.getUpcomingMovies()

        // Then
        #expect(retrievedMovies.count == 3)
        #expect(retrievedMovies[0].id == 1)
        #expect(retrievedMovies[0].title == "Test Movie 1")
        #expect(retrievedMovies[1].id == 2)
        #expect(retrievedMovies[2].id == 3)
        #expect(retrievedMovies[2].posterPath == nil)
    }

    @Test("Save empty movies array")
    func saveEmptyMoviesArray() {
        // Given
        let (sharedDataManager, _) = createTestComponents()
        defer { cleanupTest(sharedDataManager) }
        let emptyMovies: [SharedMovie] = []

        // When
        sharedDataManager.saveUpcomingMovies(emptyMovies)
        let retrievedMovies = sharedDataManager.getUpcomingMovies()

        // Then
        #expect(retrievedMovies.isEmpty)
    }

    @Test("Retrieve movies when none exists")
    func retrieveMoviesWhenNoneExists() {
        // Given
        let (sharedDataManager, _) = createTestComponents()
        defer { cleanupTest(sharedDataManager) }

        // When
        let retrievedMovies = sharedDataManager.getUpcomingMovies()

        // Then
        #expect(retrievedMovies.isEmpty)
    }

    @Test("Overwrite existing movies")
    func overwriteExistingMovies() {
        // Given
        let (sharedDataManager, testMovies) = createTestComponents()
        defer { cleanupTest(sharedDataManager) }
        sharedDataManager.saveUpcomingMovies(testMovies)
        let newMovies = [
            SharedMovie(id: 4, title: "New Movie", overview: "New overview", posterPath: "/new.jpg"),
        ]

        // When
        sharedDataManager.saveUpcomingMovies(newMovies)
        let retrievedMovies = sharedDataManager.getUpcomingMovies()

        // Then
        #expect(retrievedMovies.count == 1)
        #expect(retrievedMovies[0].id == 4)
        #expect(retrievedMovies[0].title == "New Movie")
    }

    // MARK: - Data Freshness Tests

    @Test("Is data fresh after saving")
    func isDataFreshAfterSaving() {
        // Given
        let (sharedDataManager, testMovies) = createTestComponents()
        defer { cleanupTest(sharedDataManager) }

        // When
        sharedDataManager.saveUpcomingMovies(testMovies)
        let isFresh = sharedDataManager.isDataFresh()

        // Then
        #expect(isFresh == true)
    }

    @Test("Is data fresh when no data exists")
    func isDataFreshWhenNoDataExists() {
        // Given
        let (sharedDataManager, _) = createTestComponents()
        defer { cleanupTest(sharedDataManager) }

        // When
        let isFresh = sharedDataManager.isDataFresh()

        // Then
        #expect(isFresh == false)
    }

    @Test("Is data fresh with old data")
    func isDataFreshWithOldData() {
        // Given
        let (sharedDataManager, testMovies) = createTestComponents()
        defer { cleanupTest(sharedDataManager) }
        sharedDataManager.saveUpcomingMovies(testMovies)

        // Simulate old data by directly setting an old timestamp
        let suiteName = "group.com.bruno.GitHubApp"
        let userDefaults = UserDefaults(suiteName: suiteName) ?? UserDefaults.standard

        let threeHoursAgo = Calendar.current.date(byAdding: .hour, value: -3, to: Date()) ?? Date()
        userDefaults.set(threeHoursAgo, forKey: "shared_last_update")

        // When
        let isFresh = sharedDataManager.isDataFresh()

        // Then
        #expect(isFresh == false)
    }

    // MARK: - Clear Data Tests

    @Test("Clear data")
    func clearData() {
        // Given
        let (sharedDataManager, testMovies) = createTestComponents()
        defer { cleanupTest(sharedDataManager) }
        sharedDataManager.saveUpcomingMovies(testMovies)
        #expect(!sharedDataManager.getUpcomingMovies().isEmpty)
        #expect(sharedDataManager.isDataFresh() == true)

        // When
        sharedDataManager.clearData()

        // Then
        #expect(sharedDataManager.getUpcomingMovies().isEmpty)
        #expect(sharedDataManager.isDataFresh() == false)
    }

    @Test("Retrieve movies with corrupted user defaults")
    func retrieveMoviesWithCorruptedUserDefaults() {
        // Given
        let (sharedDataManager, _) = createTestComponents()
        defer { cleanupTest(sharedDataManager) }

        // Manually set invalid data in UserDefaults
        let suiteName = "group.com.bruno.GitHubApp"
        let userDefaults = UserDefaults(suiteName: suiteName) ?? UserDefaults.standard

        // Set invalid JSON data
        let invalidData = Data("invalid json data".utf8)
        userDefaults.set(invalidData, forKey: "shared_upcoming_movies")

        // When
        let retrievedMovies = sharedDataManager.getUpcomingMovies()

        // Then - Should return empty array when decoding fails
        #expect(retrievedMovies.isEmpty)
    }
}
