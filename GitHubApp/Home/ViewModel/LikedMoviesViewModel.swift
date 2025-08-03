//
//  LikedMoviesViewModel.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import Combine
import Foundation
import SwiftUI

/**
 * ViewModel for managing liked movies functionality.
 *
 * This ViewModel handles:
 * - Loading and displaying liked movies
 * - Toggling like status for movies
 * - Persisting liked movies to UserDefaults
 * - Checking if a movie is liked
 *
 * Uses ObservableObject and @Published for SwiftUI integration.
 */
final class LikedMoviesViewModel: ObservableObject {
    /// Published array of movies that the user has liked
    @Published var likedMovies: [Movie] = []

    /// UserDefaults key for persisting liked movies
    private let likedMoviesKey = "likedMoviesKey"

    /**
     * Initialize the ViewModel and load liked movies.
     */
    init() {
        loadLikedMovies()
    }

    /**
     * Load liked movies from persistence and update the published property.
     *
     * This method refreshes the likedMovies array from UserDefaults.
     */
    func loadLikedMovies() {
        likedMovies = loadPersistedLikedMovies()
    }

    // MARK: - Liked Movies Logic

    /**
     * Toggle the liked status of a movie.
     *
     * Adds or removes the movie from the liked movies list and
     * persists the change to UserDefaults.
     *
     * - Parameter movie: The movie to toggle like status for
     */
    func toggleLike(for movie: Movie) {
        var movies = loadPersistedLikedMovies()
        if let index = movies.firstIndex(where: { $0.id == movie.id }) {
            // Remove from liked movies if already liked
            movies.remove(at: index)
        } else {
            // Add to liked movies if not liked
            movies.append(movie)
        }
        savePersistedLikedMovies(movies)
        loadLikedMovies()
    }

    /**
     * Check if a movie is currently liked by the user.
     *
     * - Parameter movie: The movie to check
     * - Returns: True if the movie is liked, false otherwise
     */
    func isLiked(movie: Movie) -> Bool {
        likedMovies.contains(where: { $0.id == movie.id })
    }

    /**
     * Save liked movies to UserDefaults for persistence.
     *
     * - Parameter movies: Array of movies to persist
     */
    private func savePersistedLikedMovies(_ movies: [Movie]) {
        if let data = try? JSONEncoder().encode(movies) {
            UserDefaults.standard.set(data, forKey: likedMoviesKey)
        }
    }

    /**
     * Load liked movies from UserDefaults.
     *
     * - Returns: Array of persisted liked movies, or empty array if none found
     */
    private func loadPersistedLikedMovies() -> [Movie] {
        guard let data = UserDefaults.standard.data(forKey: likedMoviesKey),
              let movies = try? JSONDecoder().decode([Movie].self, from: data)
        else {
            return []
        }
        return movies
    }
}
