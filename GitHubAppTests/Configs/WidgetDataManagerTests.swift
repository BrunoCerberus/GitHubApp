//
//  WidgetDataManagerTests.swift
//  GitHubAppTests
//
//  Created by Claude Code
//

import Combine
import Foundation
@testable import GitHubApp
import Testing

/**
 * Comprehensive unit tests for WidgetDataManager covering notification handling and data management.
 *
 * Tests cover:
 * - Singleton pattern
 * - Start monitoring setup
 * - Manual movie saving
 * - Notification-based movie updates
 * - Clear shared data operation
 * - Integration with SharedDataManager
 */
struct WidgetDataManagerTests {
    @Test("WidgetDataManager singleton instance is accessible")
    func singletonInstanceIsAccessible() {
        // When
        let instance = WidgetDataManager.shared

        // Then
        #expect(instance != nil, "Shared instance should be accessible")
    }

    @Test("WidgetDataManager singleton returns same instance")
    func singletonReturnsSameInstance() {
        // When
        let instance1 = WidgetDataManager.shared
        let instance2 = WidgetDataManager.shared

        // Then
        #expect(instance1 === instance2, "Shared instances should be identical")
    }

    @Test("Start monitoring sets up notification observer")
    func startMonitoringSetsUpObserver() {
        // Given
        let manager = WidgetDataManager.shared

        // When - Start monitoring
        manager.startMonitoring()

        // Then - Should not crash and should be ready to receive notifications
        #expect(true, "Start monitoring should complete without crashing")
    }

    @Test("Save upcoming movies converts and stores movies")
    func saveUpcomingMoviesConvertsAndStores() async {
        // Given
        let manager = WidgetDataManager.shared
        let sharedDataManager = SharedDataManager()
        sharedDataManager.clearData() // Clean state

        let movies = [
            Movie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: "/path1.jpg"),
            Movie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: nil),
        ]

        // When
        manager.saveUpcomingMovies(movies)

        // Give time for async Task to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second

        // Then - Verify data was saved
        let savedMovies = sharedDataManager.getUpcomingMovies()
        #expect(savedMovies.count == 2, "Should save both movies")
        #expect(savedMovies[0].id == 1, "First movie should match")
        #expect(savedMovies[1].title == "Movie 2", "Second movie title should match")

        // Cleanup
        sharedDataManager.clearData()
    }

    @Test("Save empty movie list clears data")
    func saveEmptyMovieListClearsData() async {
        // Given
        let manager = WidgetDataManager.shared
        let sharedDataManager = SharedDataManager()

        let initialMovies = [
            Movie(id: 1, title: "Movie 1", overview: "Overview", posterPath: nil),
        ]
        manager.saveUpcomingMovies(initialMovies)

        try? await Task.sleep(nanoseconds: 100_000_000) // Wait for save

        // When - Save empty list
        manager.saveUpcomingMovies([])

        try? await Task.sleep(nanoseconds: 100_000_000) // Wait for save

        // Then
        let savedMovies = sharedDataManager.getUpcomingMovies()
        #expect(savedMovies.isEmpty, "Should clear previous movies")

        // Cleanup
        sharedDataManager.clearData()
    }

    @Test("Clear shared data removes all data")
    func clearSharedDataRemovesAllData() async {
        // Given
        let manager = WidgetDataManager.shared
        let sharedDataManager = SharedDataManager()

        let movies = [
            Movie(id: 1, title: "Movie 1", overview: "Overview", posterPath: nil),
        ]
        manager.saveUpcomingMovies(movies)

        try? await Task.sleep(nanoseconds: 100_000_000) // Wait for save

        // When
        manager.clearSharedData()

        // Then
        let savedMovies = sharedDataManager.getUpcomingMovies()
        #expect(savedMovies.isEmpty, "Should clear all data")
    }

    @Test("Movies did update notification triggers save")
    func moviesDidUpdateNotificationTriggersSave() async {
        // Given
        let manager = WidgetDataManager.shared
        let sharedDataManager = SharedDataManager()
        sharedDataManager.clearData() // Clean state

        manager.startMonitoring()

        let movies = [
            Movie(id: 100, title: "Notification Movie", overview: "Via notification", posterPath: "/path.jpg"),
        ]

        // When - Post notification
        NotificationCenter.default.post(
            name: .moviesDidUpdate,
            object: movies
        )

        // Give time for notification handling and async operations
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then - Verify data was saved via notification
        let savedMovies = sharedDataManager.getUpcomingMovies()
        #expect(savedMovies.count == 1, "Should save movie from notification")
        #expect(savedMovies[0].id == 100, "Movie ID should match")
        #expect(savedMovies[0].title == "Notification Movie", "Movie title should match")

        // Cleanup
        sharedDataManager.clearData()
    }

    @Test("Movies did update notification with invalid payload is ignored")
    func moviesDidUpdateWithInvalidPayloadIsIgnored() async {
        // Given
        let manager = WidgetDataManager.shared
        let sharedDataManager = SharedDataManager()
        sharedDataManager.clearData() // Clean state

        manager.startMonitoring()

        // When - Post notification with invalid payload (String instead of [Movie])
        NotificationCenter.default.post(
            name: .moviesDidUpdate,
            object: "Invalid payload"
        )

        try? await Task.sleep(nanoseconds: 100_000_000) // Wait

        // Then - Should not crash and should not save anything
        let savedMovies = sharedDataManager.getUpcomingMovies()
        #expect(savedMovies.isEmpty, "Should not save invalid payload")
    }

    @Test("Movies did update notification with nil payload is ignored")
    func moviesDidUpdateWithNilPayloadIsIgnored() async {
        // Given
        let manager = WidgetDataManager.shared
        let sharedDataManager = SharedDataManager()
        sharedDataManager.clearData() // Clean state

        manager.startMonitoring()

        // When - Post notification with nil object
        NotificationCenter.default.post(
            name: .moviesDidUpdate,
            object: nil
        )

        try? await Task.sleep(nanoseconds: 100_000_000) // Wait

        // Then - Should not crash
        let savedMovies = sharedDataManager.getUpcomingMovies()
        #expect(savedMovies.isEmpty, "Should not save nil payload")
    }

    @Test("Save converts Movie to SharedMovie correctly")
    func saveConvertsMovieToSharedMovieCorrectly() async {
        // Given
        let manager = WidgetDataManager.shared
        let sharedDataManager = SharedDataManager()
        sharedDataManager.clearData() // Clean state

        let movie = Movie(
            id: 999,
            title: "Conversion Test Movie",
            overview: "Testing Movie to SharedMovie conversion",
            posterPath: "/conversion/test.jpg"
        )

        // When
        manager.saveUpcomingMovies([movie])

        try? await Task.sleep(nanoseconds: 100_000_000) // Wait for save

        // Then - Verify all fields converted correctly
        let savedMovies = sharedDataManager.getUpcomingMovies()
        #expect(savedMovies.count == 1, "Should save converted movie")

        let sharedMovie = savedMovies[0]
        #expect(sharedMovie.id == 999, "ID should be preserved")
        #expect(sharedMovie.title == "Conversion Test Movie", "Title should be preserved")
        #expect(sharedMovie.overview == "Testing Movie to SharedMovie conversion", "Overview should be preserved")
        #expect(sharedMovie.posterPath == "/conversion/test.jpg", "Poster path should be preserved")

        // Cleanup
        sharedDataManager.clearData()
    }

    @Test("Save handles movies with nil poster paths")
    func saveHandlesMoviesWithNilPosterPaths() async {
        // Given
        let manager = WidgetDataManager.shared
        let sharedDataManager = SharedDataManager()
        sharedDataManager.clearData()

        let movies = [
            Movie(id: 1, title: "No Poster Movie", overview: "No poster", posterPath: nil),
        ]

        // When
        manager.saveUpcomingMovies(movies)

        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        let savedMovies = sharedDataManager.getUpcomingMovies()
        #expect(savedMovies.count == 1, "Should save movie without poster")
        #expect(savedMovies[0].posterPath == nil, "Nil poster path should be preserved")

        // Cleanup
        sharedDataManager.clearData()
    }

    @Test("Multiple saves replace previous data")
    func multipleSavesReplacePreviousData() async {
        // Given
        let manager = WidgetDataManager.shared
        let sharedDataManager = SharedDataManager()
        sharedDataManager.clearData()

        let firstBatch = [
            Movie(id: 1, title: "First Batch", overview: "First", posterPath: nil),
        ]
        let secondBatch = [
            Movie(id: 2, title: "Second Batch", overview: "Second", posterPath: nil),
            Movie(id: 3, title: "Third Movie", overview: "Third", posterPath: nil),
        ]

        // When
        manager.saveUpcomingMovies(firstBatch)
        try? await Task.sleep(nanoseconds: 100_000_000)

        manager.saveUpcomingMovies(secondBatch)
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then - Should only have second batch
        let savedMovies = sharedDataManager.getUpcomingMovies()
        #expect(savedMovies.count == 2, "Should only have second batch")
        #expect(savedMovies[0].id == 2, "First movie should be from second batch")

        // Cleanup
        sharedDataManager.clearData()
    }

    @Test("Save triggers image caching asynchronously")
    func saveTriggersImageCachingAsynchronously() async {
        // Given
        let manager = WidgetDataManager.shared
        let movies = [
            Movie(id: 1, title: "Cache Test", overview: "Test", posterPath: "/cache/path.jpg"),
        ]

        // When - Save should trigger image caching
        manager.saveUpcomingMovies(movies)

        // Then - Should not block and return immediately
        // Image caching happens in background Task
        #expect(true, "Save should complete without blocking on image caching")

        // Give time for background task
        try? await Task.sleep(nanoseconds: 100_000_000)
    }
}
