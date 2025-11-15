//
//  SharedDataManagerTests.swift
//  GitHubAppTests
//
//  Created by Claude Code
//

import Foundation
@testable import GitHubApp
import Testing

/**
 * Comprehensive unit tests for SharedDataManager covering data persistence and retrieval.
 *
 * Tests cover:
 * - Saving and retrieving upcoming movies
 * - Data freshness validation
 * - Clear data operation
 * - JSON encoding/decoding
 * - Empty state handling
 * - UserDefaults integration
 *
 * Note: Tests run serially (.serialized) because they share UserDefaults storage.
 */
@Suite(.serialized)
@MainActor
struct SharedDataManagerTests {
    @Test("SharedDataManager singleton instance is accessible")
    func singletonInstanceIsAccessible() {
        // When
        let instance = SharedDataManager.shared

        // Then
        #expect(instance != nil, "Shared instance should be accessible")
    }

    @Test("SharedDataManager singleton returns same instance")
    func singletonReturnsSameInstance() {
        // When
        let instance1 = SharedDataManager.shared
        let instance2 = SharedDataManager.shared

        // Then
        #expect(instance1 === instance2, "Shared instances should be identical")
    }

    @Test("Save and retrieve upcoming movies successfully")
    func saveAndRetrieveUpcomingMovies() {
        // Given
        let manager = SharedDataManager()
        let movies = [
            SharedMovie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: "/path1.jpg"),
            SharedMovie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: "/path2.jpg"),
            SharedMovie(id: 3, title: "Movie 3", overview: "Overview 3", posterPath: nil),
        ]

        // When
        manager.saveUpcomingMovies(movies)
        let retrievedMovies = manager.getUpcomingMovies()

        // Then
        #expect(retrievedMovies.count == 3, "Should retrieve all saved movies")
        #expect(retrievedMovies[0].id == 1, "First movie should match")
        #expect(retrievedMovies[1].title == "Movie 2", "Second movie title should match")
        #expect(retrievedMovies[2].posterPath == nil, "Third movie posterPath should be nil")

        // Cleanup
        manager.clearData()
    }

    @Test("Get upcoming movies returns empty array when no data saved")
    func getUpcomingMoviesReturnsEmptyWhenNoData() {
        // Given
        let manager = SharedDataManager()
        manager.clearData() // Ensure clean state

        // When
        let movies = manager.getUpcomingMovies()

        // Then
        #expect(movies.isEmpty, "Should return empty array when no data exists")
    }

    @Test("Save empty array clears previous movies")
    func saveEmptyArrayClearsPreviousMovies() {
        // Given
        let manager = SharedDataManager()
        let movies = [
            SharedMovie(id: 1, title: "Movie 1", overview: "Overview", posterPath: nil),
        ]
        manager.saveUpcomingMovies(movies)

        // When
        manager.saveUpcomingMovies([])
        let retrievedMovies = manager.getUpcomingMovies()

        // Then
        #expect(retrievedMovies.isEmpty, "Empty save should clear previous data")

        // Cleanup
        manager.clearData()
    }

    @Test("Save replaces existing movies")
    func saveReplacesExistingMovies() {
        // Given
        let manager = SharedDataManager()
        let firstBatch = [
            SharedMovie(id: 1, title: "Movie 1", overview: "Overview", posterPath: nil),
        ]
        let secondBatch = [
            SharedMovie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: "/path.jpg"),
            SharedMovie(id: 3, title: "Movie 3", overview: "Overview 3", posterPath: nil),
        ]

        // When
        manager.saveUpcomingMovies(firstBatch)
        manager.saveUpcomingMovies(secondBatch)
        let retrievedMovies = manager.getUpcomingMovies()

        // Then
        #expect(retrievedMovies.count == 2, "Should only have second batch")
        #expect(retrievedMovies[0].id == 2, "First movie should be from second batch")
        #expect(retrievedMovies[1].id == 3, "Second movie should be from second batch")

        // Cleanup
        manager.clearData()
    }

    @Test("Data is fresh immediately after saving")
    func dataIsFreshImmediatelyAfterSaving() {
        // Given
        let manager = SharedDataManager()
        let movies = [
            SharedMovie(id: 1, title: "Movie 1", overview: "Overview", posterPath: nil),
        ]

        // When
        manager.saveUpcomingMovies(movies)
        let isFresh = manager.isDataFresh()

        // Then
        #expect(isFresh, "Data should be fresh immediately after saving")

        // Cleanup
        manager.clearData()
    }

    @Test("Data is not fresh when no data exists")
    func dataIsNotFreshWhenNoDataExists() {
        // Given
        let manager = SharedDataManager()
        manager.clearData() // Ensure clean state

        // When
        let isFresh = manager.isDataFresh()

        // Then
        #expect(!isFresh, "Data should not be fresh when no last update timestamp exists")
    }

    @Test("Clear data removes all shared data")
    func clearDataRemovesAllSharedData() {
        // Given
        let manager = SharedDataManager()
        let movies = [
            SharedMovie(id: 1, title: "Movie 1", overview: "Overview", posterPath: nil),
        ]
        manager.saveUpcomingMovies(movies)

        // When
        manager.clearData()
        let retrievedMovies = manager.getUpcomingMovies()
        let isFresh = manager.isDataFresh()

        // Then
        #expect(retrievedMovies.isEmpty, "Movies should be cleared")
        #expect(!isFresh, "Freshness should be cleared")
    }

    @Test("Clear data is idempotent")
    func clearDataIsIdempotent() {
        // Given
        let manager = SharedDataManager()
        let movies = [
            SharedMovie(id: 1, title: "Movie 1", overview: "Overview", posterPath: nil),
        ]
        manager.saveUpcomingMovies(movies)

        // When - Clear multiple times
        manager.clearData()
        manager.clearData()
        manager.clearData()

        // Then - Should not crash
        let retrievedMovies = manager.getUpcomingMovies()
        #expect(retrievedMovies.isEmpty, "Data should remain cleared")
    }

    @Test("Save handles movies with all fields populated")
    func saveHandlesMoviesWithAllFieldsPopulated() {
        // Given
        let manager = SharedDataManager()
        let movies = [
            SharedMovie(
                id: 12345,
                title: "Complete Movie",
                overview: "This is a complete overview with all fields populated",
                posterPath: "/poster/path/to/image.jpg"
            ),
        ]

        // When
        manager.saveUpcomingMovies(movies)
        let retrievedMovies = manager.getUpcomingMovies()

        // Then
        #expect(retrievedMovies.count == 1, "Should retrieve movie")
        let movie = retrievedMovies[0]
        #expect(movie.id == 12345, "ID should match")
        #expect(movie.title == "Complete Movie", "Title should match")
        #expect(movie.overview == "This is a complete overview with all fields populated", "Overview should match")
        #expect(movie.posterPath == "/poster/path/to/image.jpg", "Poster path should match")

        // Cleanup
        manager.clearData()
    }

    @Test("Save handles movies with minimal fields")
    func saveHandlesMoviesWithMinimalFields() {
        // Given
        let manager = SharedDataManager()
        let movies = [
            SharedMovie(id: 1, title: "", overview: "", posterPath: nil),
        ]

        // When
        manager.saveUpcomingMovies(movies)
        let retrievedMovies = manager.getUpcomingMovies()

        // Then
        #expect(retrievedMovies.count == 1, "Should retrieve movie")
        let movie = retrievedMovies[0]
        #expect(movie.id == 1, "ID should match")
        #expect(movie.title == "", "Empty title should be preserved")
        #expect(movie.overview == "", "Empty overview should be preserved")
        #expect(movie.posterPath == nil, "Nil posterPath should be preserved")

        // Cleanup
        manager.clearData()
    }

    @Test("Save handles large movie list")
    func saveHandlesLargeMovieList() {
        // Given
        let manager = SharedDataManager()
        let movies = (1 ... 100).map { id in
            SharedMovie(
                id: id,
                title: "Movie \(id)",
                overview: "Overview \(id)",
                posterPath: "/path\(id).jpg"
            )
        }

        // When
        manager.saveUpcomingMovies(movies)
        let retrievedMovies = manager.getUpcomingMovies()

        // Then
        #expect(retrievedMovies.count == 100, "Should retrieve all 100 movies")
        #expect(retrievedMovies[0].id == 1, "First movie should match")
        #expect(retrievedMovies[99].id == 100, "Last movie should match")

        // Cleanup
        manager.clearData()
    }

    @Test("Multiple managers share data via UserDefaults")
    func multipleManagersShareData() {
        // Given
        let manager1 = SharedDataManager()
        let manager2 = SharedDataManager()
        let movies = [
            SharedMovie(id: 1, title: "Shared Movie", overview: "Overview", posterPath: nil),
        ]

        // When
        manager1.saveUpcomingMovies(movies)
        let retrievedMovies = manager2.getUpcomingMovies()

        // Then
        #expect(retrievedMovies.count == 1, "Second manager should retrieve data saved by first")
        #expect(retrievedMovies[0].title == "Shared Movie", "Data should match")

        // Cleanup
        manager1.clearData()
    }

    @Test("Data freshness persists across manager instances")
    func dataFreshnessPersistsAcrossInstances() {
        // Given
        let manager1 = SharedDataManager()
        let manager2 = SharedDataManager()
        let movies = [
            SharedMovie(id: 1, title: "Movie", overview: "Overview", posterPath: nil),
        ]

        // When
        manager1.saveUpcomingMovies(movies)
        let isFresh = manager2.isDataFresh()

        // Then
        #expect(isFresh, "Second manager should see fresh data from first manager")

        // Cleanup
        manager1.clearData()
    }

    @Test("Clear data affects all manager instances")
    func clearDataAffectsAllInstances() {
        // Given
        let manager1 = SharedDataManager()
        let manager2 = SharedDataManager()
        let movies = [
            SharedMovie(id: 1, title: "Movie", overview: "Overview", posterPath: nil),
        ]
        manager1.saveUpcomingMovies(movies)

        // When
        manager2.clearData()
        let retrievedMovies = manager1.getUpcomingMovies()

        // Then
        #expect(retrievedMovies.isEmpty, "First manager should see cleared data")
    }
}
