//
//  MockFavoritesService.swift
//  GitHubApp
//
//  Created by bruno on storage-migration.
//

import Combine
import Foundation

/**
 * Mock implementation of FavoritesService for testing.
 *
 * This service provides mock behavior for favorite movies operations
 * without requiring actual persistence or real data.
 * Useful for unit tests and when running in test environment.
 */
final class MockFavoritesService: FavoritesService {
    // MARK: - Mock Data

    /// In-memory storage for mock favorite movies
    private var mockLikedMovies: [Movie] = []

    /// Mock movies for testing
    private let mockMovies = [
        Movie(id: 1, title: "Mock Movie 1", overview: "Test overview 1", posterPath: "/mock1.jpg"),
        Movie(id: 2, title: "Mock Movie 2", overview: "Test overview 2", posterPath: "/mock2.jpg"),
        Movie(id: 3, title: "Mock Movie 3", overview: "Test overview 3", posterPath: "/mock3.jpg"),
    ]

    // MARK: - Configuration

    /// Simulate network delays for testing
    private let simulateDelay: Bool

    /// Delay duration for simulated network calls
    private let delayDuration: TimeInterval

    /// Whether to simulate errors
    private let shouldSimulateErrors: Bool

    // MARK: - Initialization

    /**
     * Initialize the mock service with configuration options.
     *
     * - Parameter simulateDelay: Whether to simulate network delays
     * - Parameter delayDuration: Duration of simulated delays
     * - Parameter shouldSimulateErrors: Whether to simulate error conditions
     */
    init(
        simulateDelay: Bool = false,
        delayDuration: TimeInterval = 0.1,
        shouldSimulateErrors: Bool = false
    ) {
        self.simulateDelay = simulateDelay
        self.delayDuration = delayDuration
        self.shouldSimulateErrors = shouldSimulateErrors

        // Pre-populate with some mock favorite movies for testing
        mockLikedMovies = Array(mockMovies.prefix(2))
    }

    // MARK: - FavoritesService Implementation

    /**
     * Load favorite movies from mock storage.
     *
     * - Returns: Publisher emitting array of mock favorite movies or error
     */
    func loadFavoriteMovies() -> AnyPublisher<[Movie], Error> {
        if shouldSimulateErrors {
            return Fail(error: MockFavoritesServiceError.simulatedError)
                .eraseToAnyPublisher()
        }

        let publisher = Just(mockLikedMovies)
            .setFailureType(to: Error.self)

        if simulateDelay {
            return publisher
                .delay(for: .seconds(delayDuration), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        } else {
            return publisher
                .eraseToAnyPublisher()
        }
    }

    /**
     * Toggle the favorite status of a movie in mock storage.
     *
     * - Parameter movie: The movie to toggle favorite status for
     * - Returns: Publisher emitting updated array of favorite movies or error
     */
    func toggleMovieFavorite(_ movie: Movie) -> AnyPublisher<[Movie], Error> {
        if shouldSimulateErrors {
            return Fail(error: MockFavoritesServiceError.simulatedError)
                .eraseToAnyPublisher()
        }

        // Toggle movie in mock storage
        if let index = mockLikedMovies.firstIndex(where: { $0.id == movie.id }) {
            mockLikedMovies.remove(at: index)
        } else {
            mockLikedMovies.append(movie)
        }

        let publisher = Just(mockLikedMovies)
            .setFailureType(to: Error.self)

        if simulateDelay {
            return publisher
                .delay(for: .seconds(delayDuration), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        } else {
            return publisher
                .eraseToAnyPublisher()
        }
    }

    /**
     * Clear all favorite movies from mock storage.
     *
     * - Returns: Publisher emitting completion or error
     */
    func clearAllFavoriteMovies() -> AnyPublisher<Void, Error> {
        if shouldSimulateErrors {
            return Fail(error: MockFavoritesServiceError.simulatedError)
                .eraseToAnyPublisher()
        }

        mockLikedMovies.removeAll()

        let publisher = Just(())
            .setFailureType(to: Error.self)

        if simulateDelay {
            return publisher
                .delay(for: .seconds(delayDuration), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        } else {
            return publisher
                .eraseToAnyPublisher()
        }
    }

    /**
     * Check if a movie is liked in mock storage.
     *
     * - Parameter movie: The movie to check
     * - Returns: Publisher emitting boolean result or error
     */
    func isMovieLiked(_ movie: Movie) -> AnyPublisher<Bool, Error> {
        if shouldSimulateErrors {
            return Fail(error: MockFavoritesServiceError.simulatedError)
                .eraseToAnyPublisher()
        }

        let isLiked = mockLikedMovies.contains(where: { $0.id == movie.id })

        let publisher = Just(isLiked)
            .setFailureType(to: Error.self)

        if simulateDelay {
            return publisher
                .delay(for: .seconds(delayDuration), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        } else {
            return publisher
                .eraseToAnyPublisher()
        }
    }
}

// MARK: - Mock Error Types

/**
 * Errors that can be simulated by MockFavoritesService.
 */
enum MockFavoritesServiceError: LocalizedError {
    case simulatedError
    case networkError
    case dataCorruption

    var errorDescription: String? {
        switch self {
        case .simulatedError:
            "Simulated error for testing"
        case .networkError:
            "Simulated network error"
        case .dataCorruption:
            "Simulated data corruption error"
        }
    }
}

// MARK: - Test Helper Methods

extension MockFavoritesService {
    /**
     * Reset mock storage to initial state.
     * Useful for test setup and teardown.
     */
    func resetMockStorage() {
        mockLikedMovies = Array(mockMovies.prefix(2))
    }

    /**
     * Set specific mock favorite movies for testing scenarios.
     *
     * - Parameter movies: Movies to set as liked
     */
    func setMockLikedMovies(_ movies: [Movie]) {
        mockLikedMovies = movies
    }

    /**
     * Get current mock favorite movies for test assertions.
     *
     * - Returns: Current array of mock favorite movies
     */
    func getCurrentMockLikedMovies() -> [Movie] {
        mockLikedMovies
    }
}
