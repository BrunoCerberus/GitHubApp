//
//  LiveFavoritesService.swift
//  GitHubApp
//
//  Created by bruno on feature/liked-clean-architecture.
//

import Combine
import Foundation

/**
 * Live implementation of FavoritesService.
 *
 * NOTE: This service is primarily kept for protocol compatibility.
 * The actual favorite movies operations are handled by the FavoritesDomainInteractor
 * which acts as the bridge between FavoritesService and StorageService.
 *
 * The FavoritesDomainInteractor calls StorageService directly, following
 * the principle that domain interactors should coordinate between services,
 * not services depending on other services.
 */
final class LiveFavoritesService: FavoritesService {
    // MARK: - Initialization

    /**
     * Initialize the service.
     */
    init() {}

    // MARK: - FavoritesService Implementation

    /**
     * Load favorite movies from persistence.
     * NOTE: This is deprecated. Use FavoritesDomainInteractor instead.
     *
     * - Returns: Publisher emitting array of favorite movies or error
     */
    func loadFavoriteMovies() -> AnyPublisher<[Movie], Error> {
        Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    /**
     * Toggle the favorite status of a movie.
     * NOTE: This is deprecated. Use FavoritesDomainInteractor instead.
     *
     * - Parameter movie: The movie to toggle favorite status for
     * - Returns: Publisher emitting updated array of favorite movies or error
     */
    func toggleMovieFavorite(_: Movie) -> AnyPublisher<[Movie], Error> {
        Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    /**
     * Clear all favorite movies.
     * NOTE: This is deprecated. Use FavoritesDomainInteractor instead.
     *
     * - Returns: Publisher emitting completion or error
     */
    func clearAllFavoriteMovies() -> AnyPublisher<Void, Error> {
        Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    /**
     * Check if a movie is liked.
     * NOTE: This is deprecated. Use FavoritesDomainInteractor instead.
     *
     * - Parameter movie: The movie to check
     * - Returns: Publisher emitting boolean result or error
     */
    func isMovieLiked(_: Movie) -> AnyPublisher<Bool, Error> {
        Just(false)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

// MARK: - Error Types

/**
 * Errors that can occur in the FavoritesService.
 */
enum FavoritesServiceError: LocalizedError {
    case serviceUnavailable
    case encodingFailed(Error)
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .serviceUnavailable:
            "Favorites service is unavailable"
        case let .encodingFailed(error):
            "Failed to encode favorite movies: \(error.localizedDescription)"
        case let .decodingFailed(error):
            "Failed to decode favorite movies: \(error.localizedDescription)"
        }
    }
}
