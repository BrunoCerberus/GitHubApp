//
//  HomeViewModel.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import Combine
import Foundation
import Observation

/**
 * ViewModel for the Home screen managing movie data and user interactions.
 *
 * This ViewModel handles:
 * - Fetching and displaying upcoming movies
 * - Search functionality with debouncing
 * - Like/unlike movie functionality with persistence
 * - Error handling and state management
 *
 * Uses @Observable for SwiftUI integration and Combine for reactive programming.
 */
@Observable
final class HomeViewModel {
    /// Currently displayed movies (either upcoming or search results)
    var movies: [Movie] = []

    /// Current search query entered by the user
    var searchQuery: String = ""

    /// Error message to display to the user
    var error: String?

    /// Movies that the user has liked (subset of current movies)
    var likedMovies: [Movie] = []

    /// Combine cancellables for memory management
    private var cancellables = Set<AnyCancellable>()

    /// Network service for API calls
    private let service: HomeServiceProtocol

    /// UserDefaults key for persisting liked movies
    private let likedMoviesKey = "likedMoviesKey"

    /**
     * Initialize the ViewModel with optional service dependency.
     *
     * - Parameter service: Network service for API calls (defaults to HomeService)
     */
    init(service: HomeServiceProtocol = HomeService()) {
        self.service = service
        fetchData()
        loadLikedMovies()
    }

    /**
     * Fetch upcoming movies from the API.
     *
     * Makes a network request to get upcoming movies and updates
     * the movies array. Also updates liked movies to reflect
     * current movie list.
     */
    func fetchData() {
        service.fetchMovies()
            .map(\.results)
            .catch { [weak self] error -> AnyPublisher<[Movie], Never> in
                self?.handleError(error)
                return Just([]).eraseToAnyPublisher()
            }
            .sink { [weak self] movies in
                self?.movies = movies
                self?.updateLikedMovies()
            }
            .store(in: &cancellables)
    }

    /**
     * Search for movies by query string.
     *
     * Makes a network request to search for movies matching the query
     * and updates the movies array. Also updates liked movies to reflect
     * current movie list.
     *
     * - Parameter query: Search term to find movies
     */
    func searchMovies(query: String) {
        service.searchMovies(with: query)
            .map(\.results)
            .catch { [weak self] error -> AnyPublisher<[Movie], Never> in
                self?.handleError(error)
                return Just([]).eraseToAnyPublisher()
            }
            .sink { [weak self] movies in
                self?.movies = movies
                self?.updateLikedMovies()
            }
            .store(in: &cancellables)
    }

    /**
     * Toggle the liked status of a movie.
     *
     * Adds or removes the movie from the liked movies list and
     * persists the change to UserDefaults.
     *
     * - Parameter movie: The movie to toggle like status for
     */
    func toggleLike(for movie: Movie) {
        var likedMovies = loadPersistedLikedMovies()
        if let index = likedMovies.firstIndex(where: { $0.id == movie.id }) {
            // Remove from liked movies if already liked
            likedMovies.remove(at: index)
        } else {
            // Add to liked movies if not liked
            likedMovies.append(movie)
        }
        savePersistedLikedMovies(likedMovies)
        updateLikedMovies()
    }

    /**
     * Load liked movies from persistence.
     *
     * Called during initialization to restore liked movies state.
     */
    func loadLikedMovies() {
        updateLikedMovies()
    }

    /**
     * Update the liked movies list to reflect current movie list.
     *
     * Filters persisted liked movies to only include those that
     * are currently in the movies array (either upcoming or search results).
     */
    private func updateLikedMovies() {
        let persistedLikedMovies = loadPersistedLikedMovies()
        // Filter liked movies to only include those that are currently in the movies list
        likedMovies = movies.filter { movie in
            persistedLikedMovies.contains(where: { $0.id == movie.id })
        }
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
     * Handle and display errors from API calls.
     *
     * - Parameter error: The error that occurred
     */
    private func handleError(_ error: Error) {
        self.error = error.localizedDescription
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

    /**
     * Cleanup method called when ViewModel is deallocated.
     *
     * Logs deallocation for debugging purposes.
     */
    deinit {
        print("HomeViewModel deallocated")
    }
}
