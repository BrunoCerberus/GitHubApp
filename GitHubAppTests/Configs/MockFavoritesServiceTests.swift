//
//  MockFavoritesServiceTests.swift
//  GitHubAppTests
//
//  Created by Claude Code to improve test coverage
//

import Combine
import Foundation
@testable import GitHubApp
import Testing

/**
 * Comprehensive unit tests for MockFavoritesService.
 *
 * Tests cover:
 * - Loading favorite movies
 * - Toggling favorite status (add/remove)
 * - Clearing all favorites
 * - Checking if movie is liked
 * - Error simulation
 * - Delay simulation
 * - Helper methods (reset, set, get)
 */
@MainActor
struct MockFavoritesServiceTests {
    // MARK: - Load Favorites Tests

    @Test("Load favorite movies returns pre-populated movies")
    func loadFavoriteMoviesReturnsPrePopulatedMovies() async throws {
        // Given
        let service = MockFavoritesService()
        var cancellables = Set<AnyCancellable>()
        var receivedMovies: [Movie] = []

        // When
        let expectation = expectation()
        service.loadFavoriteMovies()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { movies in
                    receivedMovies = movies
                }
            )
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 1.0)

        // Then
        #expect(receivedMovies.count == 2, "Should have 2 pre-populated movies")
    }

    @Test("Load favorite movies with error simulation fails")
    func loadFavoriteMoviesWithErrorSimulationFails() async throws {
        // Given
        let service = MockFavoritesService(shouldSimulateErrors: true)
        var cancellables = Set<AnyCancellable>()
        var receivedError: Error?

        // When
        let expectation = expectation()
        service.loadFavoriteMovies()
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        receivedError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 1.0)

        // Then
        #expect(receivedError != nil, "Should receive error")
    }

    @Test("Load favorite movies with delay simulation takes time")
    func loadFavoriteMoviesWithDelaySimulationTakesTime() async throws {
        // Given
        let service = MockFavoritesService(simulateDelay: true, delayDuration: 0.05)
        var cancellables = Set<AnyCancellable>()
        var receivedMovies: [Movie] = []
        let startTime = Date()

        // When
        let expectation = expectation()
        service.loadFavoriteMovies()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { movies in
                    receivedMovies = movies
                }
            )
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 1.0)
        let elapsed = Date().timeIntervalSince(startTime)

        // Then
        #expect(receivedMovies.count == 2, "Should return movies")
        #expect(elapsed >= 0.05, "Should respect delay duration")
    }

    // MARK: - Toggle Favorite Tests

    @Test("Toggle movie favorite adds new movie")
    func toggleMovieFavoriteAddsNewMovie() async throws {
        // Given
        let service = MockFavoritesService()
        let newMovie = Movie(id: 999, title: "New Movie", overview: "Test", posterPath: nil)
        var cancellables = Set<AnyCancellable>()
        var receivedMovies: [Movie] = []

        // When
        let expectation = expectation()
        service.toggleMovieFavorite(newMovie)
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { movies in
                    receivedMovies = movies
                }
            )
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 1.0)

        // Then
        #expect(receivedMovies.count == 3, "Should add new movie")
        #expect(receivedMovies.contains(where: { $0.id == 999 }), "Should contain new movie")
    }

    @Test("Toggle movie favorite removes existing movie")
    func toggleMovieFavoriteRemovesExistingMovie() async throws {
        // Given
        let service = MockFavoritesService()
        let existingMovie = Movie(id: 1, title: "Mock Movie 1", overview: "Test", posterPath: nil)
        var cancellables = Set<AnyCancellable>()
        var receivedMovies: [Movie] = []

        // When
        let expectation = expectation()
        service.toggleMovieFavorite(existingMovie)
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { movies in
                    receivedMovies = movies
                }
            )
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 1.0)

        // Then
        #expect(receivedMovies.count == 1, "Should remove existing movie")
        #expect(!receivedMovies.contains(where: { $0.id == 1 }), "Should not contain removed movie")
    }

    @Test("Toggle movie favorite with error simulation fails")
    func toggleMovieFavoriteWithErrorSimulationFails() async throws {
        // Given
        let service = MockFavoritesService(shouldSimulateErrors: true)
        let movie = Movie(id: 1, title: "Test", overview: "Test", posterPath: nil)
        var cancellables = Set<AnyCancellable>()
        var receivedError: Error?

        // When
        let expectation = expectation()
        service.toggleMovieFavorite(movie)
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        receivedError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 1.0)

        // Then
        #expect(receivedError != nil, "Should receive error")
    }

    @Test("Toggle movie favorite with delay simulation takes time")
    func toggleMovieFavoriteWithDelaySimulationTakesTime() async throws {
        // Given
        let service = MockFavoritesService(simulateDelay: true, delayDuration: 0.05)
        let movie = Movie(id: 999, title: "Test", overview: "Test", posterPath: nil)
        var cancellables = Set<AnyCancellable>()
        let startTime = Date()

        // When
        let expectation = expectation()
        service.toggleMovieFavorite(movie)
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 1.0)
        let elapsed = Date().timeIntervalSince(startTime)

        // Then
        #expect(elapsed >= 0.05, "Should respect delay duration")
    }

    // MARK: - Clear All Favorites Tests

    @Test("Clear all favorite movies removes all movies")
    func clearAllFavoriteMoviesRemovesAllMovies() async throws {
        // Given
        let service = MockFavoritesService()
        var cancellables = Set<AnyCancellable>()
        var clearSucceeded = false

        // When
        let expectation = expectation()
        expectation.expectedFulfillmentCount = 2

        service.clearAllFavoriteMovies()
            .sink(
                receiveCompletion: { _ in
                    clearSucceeded = true
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        service.loadFavoriteMovies()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { movies in
                    #expect(movies.isEmpty, "Should have no movies after clear")
                }
            )
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 1.0)

        // Then
        #expect(clearSucceeded, "Clear should succeed")
    }

    @Test("Clear all favorite movies with error simulation fails")
    func clearAllFavoriteMoviesWithErrorSimulationFails() async throws {
        // Given
        let service = MockFavoritesService(shouldSimulateErrors: true)
        var cancellables = Set<AnyCancellable>()
        var receivedError: Error?

        // When
        let expectation = expectation()
        service.clearAllFavoriteMovies()
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        receivedError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 1.0)

        // Then
        #expect(receivedError != nil, "Should receive error")
    }

    @Test("Clear all favorite movies with delay simulation takes time")
    func clearAllFavoriteMoviesWithDelaySimulationTakesTime() async throws {
        // Given
        let service = MockFavoritesService(simulateDelay: true, delayDuration: 0.05)
        var cancellables = Set<AnyCancellable>()
        let startTime = Date()

        // When
        let expectation = expectation()
        service.clearAllFavoriteMovies()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 1.0)
        let elapsed = Date().timeIntervalSince(startTime)

        // Then
        #expect(elapsed >= 0.05, "Should respect delay duration")
    }

    // MARK: - Is Movie Liked Tests

    @Test("Is movie liked returns true for existing movie")
    func isMovieLikedReturnsTrueForExistingMovie() async throws {
        // Given
        let service = MockFavoritesService()
        let existingMovie = Movie(id: 1, title: "Mock Movie 1", overview: "Test", posterPath: nil)
        var cancellables = Set<AnyCancellable>()
        var isLiked = false

        // When
        let expectation = expectation()
        service.isMovieLiked(existingMovie)
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { liked in
                    isLiked = liked
                }
            )
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 1.0)

        // Then
        #expect(isLiked, "Should return true for existing movie")
    }

    @Test("Is movie liked returns false for non-existing movie")
    func isMovieLikedReturnsFalseForNonExistingMovie() async throws {
        // Given
        let service = MockFavoritesService()
        let nonExistingMovie = Movie(id: 999, title: "New Movie", overview: "Test", posterPath: nil)
        var cancellables = Set<AnyCancellable>()
        var isLiked = true

        // When
        let expectation = expectation()
        service.isMovieLiked(nonExistingMovie)
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { liked in
                    isLiked = liked
                }
            )
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 1.0)

        // Then
        #expect(!isLiked, "Should return false for non-existing movie")
    }

    @Test("Is movie liked with error simulation fails")
    func isMovieLikedWithErrorSimulationFails() async throws {
        // Given
        let service = MockFavoritesService(shouldSimulateErrors: true)
        let movie = Movie(id: 1, title: "Test", overview: "Test", posterPath: nil)
        var cancellables = Set<AnyCancellable>()
        var receivedError: Error?

        // When
        let expectation = expectation()
        service.isMovieLiked(movie)
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        receivedError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 1.0)

        // Then
        #expect(receivedError != nil, "Should receive error")
    }

    @Test("Is movie liked with delay simulation takes time")
    func isMovieLikedWithDelaySimulationTakesTime() async throws {
        // Given
        let service = MockFavoritesService(simulateDelay: true, delayDuration: 0.05)
        let movie = Movie(id: 1, title: "Test", overview: "Test", posterPath: nil)
        var cancellables = Set<AnyCancellable>()
        let startTime = Date()

        // When
        let expectation = expectation()
        service.isMovieLiked(movie)
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 1.0)
        let elapsed = Date().timeIntervalSince(startTime)

        // Then
        #expect(elapsed >= 0.05, "Should respect delay duration")
    }

    // MARK: - Helper Methods Tests

    @Test("Reset mock storage restores initial state")
    func resetMockStorageRestoresInitialState() {
        // Given
        let service = MockFavoritesService()
        service.setMockLikedMovies([])

        // When
        service.resetMockStorage()
        let currentMovies = service.getCurrentMockLikedMovies()

        // Then
        #expect(currentMovies.count == 2, "Should restore to 2 initial movies")
    }

    @Test("Set mock liked movies updates storage")
    func setMockLikedMoviesUpdatesStorage() {
        // Given
        let service = MockFavoritesService()
        let customMovies = [
            Movie(id: 100, title: "Custom 1", overview: "Test", posterPath: nil),
            Movie(id: 200, title: "Custom 2", overview: "Test", posterPath: nil),
            Movie(id: 300, title: "Custom 3", overview: "Test", posterPath: nil),
        ]

        // When
        service.setMockLikedMovies(customMovies)
        let currentMovies = service.getCurrentMockLikedMovies()

        // Then
        #expect(currentMovies.count == 3, "Should have 3 custom movies")
        #expect(currentMovies[0].id == 100, "Should contain first custom movie")
        #expect(currentMovies[1].id == 200, "Should contain second custom movie")
        #expect(currentMovies[2].id == 300, "Should contain third custom movie")
    }

    @Test("Get current mock liked movies returns current state")
    func getCurrentMockLikedMoviesReturnsCurrentState() {
        // Given
        let service = MockFavoritesService()

        // When
        let currentMovies = service.getCurrentMockLikedMovies()

        // Then
        #expect(currentMovies.count == 2, "Should return current state")
    }

    // MARK: - Error Type Tests

    @Test("MockFavoritesServiceError has correct descriptions")
    func mockFavoritesServiceErrorHasCorrectDescriptions() {
        // Given
        let simulatedError = MockFavoritesServiceError.simulatedError
        let networkError = MockFavoritesServiceError.networkError
        let dataCorruptionError = MockFavoritesServiceError.dataCorruption

        // Then
        #expect(simulatedError.errorDescription == "Simulated error for testing")
        #expect(networkError.errorDescription == "Simulated network error")
        #expect(dataCorruptionError.errorDescription == "Simulated data corruption error")
    }
}

/**
 * Helper for async testing expectations.
 */
private func expectation() -> TestExpectation {
    TestExpectation()
}

private final class TestExpectation: @unchecked Sendable {
    private var fulfilled = false
    private var fulfillmentCount = 0
    var expectedFulfillmentCount = 1

    func fulfill() {
        fulfillmentCount += 1
        if fulfillmentCount >= expectedFulfillmentCount {
            fulfilled = true
        }
    }

    func waitForFulfillment(timeout: TimeInterval) async {
        let deadline = Date().addingTimeInterval(timeout)
        while !fulfilled, Date() < deadline {
            try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
        }
    }
}
