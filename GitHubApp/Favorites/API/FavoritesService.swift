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
    /// Load favorite movies from persistence
    func loadFavoriteMovies() -> AnyPublisher<[Movie], Error>

    /// Toggle the favorite status of a movie
    func toggleMovieFavorite(_ movie: Movie) -> AnyPublisher<[Movie], Error>

    /// Clear all favorite movies
    func clearAllFavoriteMovies() -> AnyPublisher<Void, Error>

    /// Check if a movie is liked
    func isMovieLiked(_ movie: Movie) -> AnyPublisher<Bool, Error>
}
