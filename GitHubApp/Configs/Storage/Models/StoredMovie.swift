//
//  StoredMovie.swift
//  GitHubApp
//
//  Created by bruno on storage-migration.
//

import Foundation
import SwiftData

/**
 * SwiftData model for persisting movie information.
 *
 * This model represents a movie stored in the local database,
 * designed to work with SwiftData for efficient persistence
 * and querying operations.
 *
 * The model maintains compatibility with the existing Movie struct
 * while providing SwiftData-specific annotations and functionality.
 */
@Model
final class StoredMovie {
    /// Unique movie identifier from The Movie Database
    @Attribute(.unique) var movieID: Int

    /// Movie title
    var title: String

    /// Movie plot summary/description
    var overview: String

    /// Poster image path (relative to base image URL)
    var posterPath: String?

    /// Context for organizing movies (e.g., "liked_movies", "widget_data")
    var context: String

    /// Timestamp when the movie was saved
    var savedAt: Date

    /// Timestamp when the movie was last updated
    var updatedAt: Date

    // MARK: - Initialization

    /**
     * Initialize a StoredMovie from a Movie model.
     *
     * - Parameters:
     *   - movie: The Movie to convert
     *   - context: Storage context for organization
     */
    init(from movie: Movie, context: String) {
        movieID = movie.id
        title = movie.title
        overview = movie.overview
        posterPath = movie.posterPath
        self.context = context
        savedAt = Date()
        updatedAt = Date()
    }

    /**
     * Initialize a StoredMovie with explicit parameters.
     *
     * - Parameters:
     *   - movieID: Unique movie identifier
     *   - title: Movie title
     *   - overview: Movie description
     *   - posterPath: Poster image path
     *   - context: Storage context
     */
    init(movieID: Int, title: String, overview: String, posterPath: String?, context: String) {
        self.movieID = movieID
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.context = context
        savedAt = Date()
        updatedAt = Date()
    }

    // MARK: - Convenience Methods

    /**
     * Convert StoredMovie back to Movie model.
     *
     * This allows seamless integration with existing code
     * that expects Movie objects.
     *
     * - Returns: Movie model representation
     */
    func toMovie() -> Movie {
        Movie(
            id: movieID,
            title: title,
            overview: overview,
            posterPath: posterPath
        )
    }

    /**
     * Update the stored movie with new data.
     *
     * - Parameter movie: Movie with updated information
     */
    func update(from movie: Movie) {
        title = movie.title
        overview = movie.overview
        posterPath = movie.posterPath
        updatedAt = Date()
    }
}

// MARK: - SwiftData Queries

extension StoredMovie {
    /**
     * Predicate for fetching movies by context.
     *
     * - Parameter context: The context to filter by
     * - Returns: Predicate for SwiftData queries
     */
    static func contextPredicate(_ context: String) -> Predicate<StoredMovie> {
        #Predicate<StoredMovie> { movie in
            movie.context == context
        }
    }

    /**
     * Predicate for fetching a specific movie by ID and context.
     *
     * - Parameters:
     *   - movieID: The movie ID to search for
     *   - context: The context to filter by
     * - Returns: Predicate for SwiftData queries
     */
    static func moviePredicate(movieID: Int, context: String) -> Predicate<StoredMovie> {
        #Predicate<StoredMovie> { movie in
            movie.movieID == movieID && movie.context == context
        }
    }
}
