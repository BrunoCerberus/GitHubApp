//
//  LiveFavoritesService.swift
//  GitHubApp
//
//  Created by bruno on feature/liked-clean-architecture.
//

import Combine
import Foundation
import SwiftData

/**
 * Live implementation of FavoritesService.
 *
 * This service handles all persistence operations for liked movies using StorageService.
 * It provides a reactive interface using Combine publishers while leveraging
 * the modern SwiftData-based storage system.
 */
final class LiveFavoritesService: FavoritesService {
    // MARK: - Dependencies

    /// Storage service for persistence operations
    private let storageService: StorageServiceProtocol

    // MARK: - Initialization

    /**
     * Initialize the service with dependencies.
     *
     * - Parameter storageService: Storage service for persistence (defaults to shared instance)
     */
    init(storageService: StorageServiceProtocol? = nil) {
        if let storageService {
            self.storageService = storageService
        } else {
            // Use the shared storage service from factory
            do {
                self.storageService = try StorageServiceFactory.shared.getStorageService()
            } catch {
                // Fallback to legacy UserDefaults service if SwiftData fails
                print("⚠️ Failed to initialize SwiftData storage, falling back to UserDefaults: \(error)")
                self.storageService = UserDefaultsStorageService()
            }
        }
    }

    // MARK: - FavoritesService Implementation

    /**
     * Load liked movies from persistence.
     *
     * - Returns: Publisher emitting array of liked movies or error
     */
    func loadLikedMovies() -> AnyPublisher<[Movie], Error> {
        Future { [weak self] promise in
            guard let self else {
                promise(.failure(FavoritesServiceError.serviceUnavailable))
                return
            }

            Task {
                do {
                    let movies = try await self.storageService.fetchLikedMovies()
                    promise(.success(movies))
                } catch {
                    promise(.failure(error))
                }
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
                promise(.failure(FavoritesServiceError.serviceUnavailable))
                return
            }

            Task {
                do {
                    let movies = try await self.storageService.toggleMovieLike(movie)
                    promise(.success(movies))
                } catch {
                    promise(.failure(error))
                }
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
                promise(.failure(FavoritesServiceError.serviceUnavailable))
                return
            }

            Task {
                do {
                    try await self.storageService.clearLikedMovies()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
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
        Future { [weak self] promise in
            guard let self else {
                promise(.failure(FavoritesServiceError.serviceUnavailable))
                return
            }

            Task {
                do {
                    let isLiked = try await self.storageService.isMovieLiked(movie)
                    promise(.success(isLiked))
                } catch {
                    promise(.failure(error))
                }
            }
        }
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
