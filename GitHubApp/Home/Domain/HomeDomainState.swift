//
//  HomeDomainState.swift
//  GitHubApp
//
//  Created by bruno on feature/home-clean-architecture.
//

import Foundation

/**
 * Domain state for the Home feature business logic.
 *
 * This represents the current state of the Home domain,
 * containing all data and status information needed by the business logic.
 */
struct HomeDomainState: Equatable {
    /// Current list of movies (upcoming or search results)
    var movies: [Movie]

    /// Movies that the user has liked
    var likedMovies: [Movie]

    /// Current loading state
    var isLoading: Bool

    /// Current error state
    var error: String?

    /// Current search query
    var searchQuery: String?

    /// Default initial state
    static let initial = HomeDomainState(
        movies: [],
        likedMovies: [],
        isLoading: false,
        error: nil,
        searchQuery: nil
    )
}
