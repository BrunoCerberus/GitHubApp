//
//  FavoritesService.swift
//  GitHubApp
//
//  Created by bruno on feature/liked-clean-architecture.
//

import Combine
import Foundation

/**
 * Protocol defining the interface for favorites movies service operations.
 */
protocol FavoritesService {
    /// Load liked movies from persistence
    func loadLikedMovies() -> AnyPublisher<[Movie], Error>

    /// Toggle the liked status of a movie
    func toggleMovieLike(_ movie: Movie) -> AnyPublisher<[Movie], Error>

    /// Clear all liked movies
    func clearAllLikedMovies() -> AnyPublisher<Void, Error>

    /// Check if a movie is liked
    func isMovieLiked(_ movie: Movie) -> AnyPublisher<Bool, Error>
}
