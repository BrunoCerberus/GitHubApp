//
//  LikedService.swift
//  GitHubApp
//
//  Created by bruno on feature/liked-clean-architecture.
//

import Combine
import Foundation

/**
 * Protocol defining the interface for liked movies service operations.
 */
protocol LikedServiceProtocol {
    /// Load liked movies from persistence
    func loadLikedMovies() -> AnyPublisher<[Movie], Error>

    /// Toggle the liked status of a movie
    func toggleMovieLike(_ movie: Movie) -> AnyPublisher<[Movie], Error>

    /// Clear all liked movies
    func clearAllLikedMovies() -> AnyPublisher<Void, Error>

    /// Check if a movie is liked
    func isMovieLiked(_ movie: Movie) -> AnyPublisher<Bool, Error>
}

/**
 * Service responsible for managing liked movies persistence and operations.
 *
 * This service handles all persistence operations for liked movies using UserDefaults.
 * It provides a reactive interface using Combine publishers.
 */
final class LikedService: LikedServiceProtocol {
    // MARK: - Constants

    /// UserDefaults key for persisting liked movies
    private let likedMoviesKey: String = "likedMoviesKey"

    // MARK: - Dependencies

    /// UserDefaults instance for persistence
    private let userDefaults: UserDefaults

    /// JSON encoder for serialization
    private let encoder: JSONEncoder

    /// JSON decoder for deserialization
    private let decoder: JSONDecoder

    // MARK: - Initialization

    /**
     * Initialize the service with dependencies.
     *
     * - Parameter userDefaults: UserDefaults instance for persistence (defaults to .standard)
     */
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        encoder = JSONEncoder()
        decoder = JSONDecoder()
    }

    // MARK: - LikedServiceProtocol Implementation

    /**
     * Load liked movies from persistence.
     *
     * - Returns: Publisher emitting array of liked movies or error
     */
    func loadLikedMovies() -> AnyPublisher<[Movie], Error> {
        Future { [weak self] promise in
            guard let self else {
                promise(.failure(LikedServiceError.serviceUnavailable))
                return
            }

            do {
                let movies = try loadPersistedLikedMovies()
                promise(.success(movies))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    /**
     * Toggle the liked status of a movie.
     *
     * - Parameter movie: The movie to toggle like status for
     * - Returns: Publisher emitting updated array of liked movies or error
     */
    func toggleMovieLike(_ movie: Movie) -> AnyPublisher<[Movie], Error> {
        Future { [weak self] promise in
            guard let self else {
                promise(.failure(LikedServiceError.serviceUnavailable))
                return
            }

            do {
                var movies = try loadPersistedLikedMovies()

                if let index = movies.firstIndex(where: { $0.id == movie.id }) {
                    // Remove from liked movies if already liked
                    movies.remove(at: index)
                } else {
                    // Add to liked movies if not liked
                    movies.append(movie)
                }

                try savePersistedLikedMovies(movies)
                promise(.success(movies))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    /**
     * Clear all liked movies.
     *
     * - Returns: Publisher emitting completion or error
     */
    func clearAllLikedMovies() -> AnyPublisher<Void, Error> {
        Future { [weak self] promise in
            guard let self else {
                promise(.failure(LikedServiceError.serviceUnavailable))
                return
            }

            do {
                try savePersistedLikedMovies([])
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    /**
     * Check if a movie is liked.
     *
     * - Parameter movie: The movie to check
     * - Returns: Publisher emitting boolean result or error
     */
    func isMovieLiked(_ movie: Movie) -> AnyPublisher<Bool, Error> {
        loadLikedMovies()
            .map { likedMovies in
                likedMovies.contains(where: { $0.id == movie.id })
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private Helper Methods

    /**
     * Load liked movies from UserDefaults.
     *
     * - Returns: Array of persisted liked movies
     * - Throws: LikedServiceError if decoding fails
     */
    private func loadPersistedLikedMovies() throws -> [Movie] {
        guard let data = userDefaults.data(forKey: likedMoviesKey) else {
            return [] // No data found, return empty array
        }

        do {
            return try decoder.decode([Movie].self, from: data)
        } catch {
            throw LikedServiceError.decodingFailed(error)
        }
    }

    /**
     * Save liked movies to UserDefaults.
     *
     * - Parameter movies: Array of movies to persist
     * - Throws: LikedServiceError if encoding fails
     */
    private func savePersistedLikedMovies(_ movies: [Movie]) throws {
        do {
            let data = try encoder.encode(movies)
            userDefaults.set(data, forKey: likedMoviesKey)
        } catch {
            throw LikedServiceError.encodingFailed(error)
        }
    }
}

// MARK: - Error Types

/**
 * Errors that can occur in the LikedService.
 */
enum LikedServiceError: LocalizedError {
    case serviceUnavailable
    case encodingFailed(Error)
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .serviceUnavailable:
            "Liked service is unavailable"
        case let .encodingFailed(error):
            "Failed to encode liked movies: \(error.localizedDescription)"
        case let .decodingFailed(error):
            "Failed to decode liked movies: \(error.localizedDescription)"
        }
    }
}
