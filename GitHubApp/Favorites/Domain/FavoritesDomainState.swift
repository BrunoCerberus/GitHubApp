//
//  FavoritesDomainState.swift
//  GitHubApp
//
//  Created by bruno on feature/liked-clean-architecture.
//

import Foundation

/**
 * Domain state for the Favorites feature business logic.
 *
 * This represents the current state of the Favorites domain,
 * containing all data and status information needed by the business logic.
 */
struct FavoritesDomainState: Equatable {
    /// Movies that the user has favorited
    var favoriteMovies: [Movie]

    /// Current loading state
    var isLoading: Bool

    /// Current error state
    var error: String?

    /// Default initial state
    static let initial = FavoritesDomainState(
        favoriteMovies: [],
        isLoading: false,
        error: nil
    )
}
