//
//  MovieDetailsDomainState.swift
//  GitHubApp
//
//  Created by Claude Code
//

import Foundation

/**
 * Domain state for the MovieDetails feature business logic.
 *
 * This represents the current state of the MovieDetails domain,
 * containing all data and status information needed by the business logic.
 */
struct MovieDetailsDomainState: Equatable {
    /// The movie being displayed
    var movie: Movie

    /// Cast and crew members for the movie
    var credits: [MovieCastMember]

    /// User and critic reviews for the movie
    var reviews: [MovieReview]

    /// Movies that the user has favorited
    var favoriteMovies: [Movie]

    /// Current loading state
    var isLoading: Bool

    /// Current error state
    var error: String?

    /**
     * Default initial state for a given movie.
     *
     * - Parameter movie: The movie to display details for
     * - Returns: Initial state with the given movie
     */
    static func initial(for movie: Movie) -> MovieDetailsDomainState {
        MovieDetailsDomainState(
            movie: movie,
            credits: [],
            reviews: [],
            favoriteMovies: [],
            isLoading: true,
            error: nil
        )
    }
}
