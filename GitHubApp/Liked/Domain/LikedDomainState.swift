//
//  LikedDomainState.swift
//  GitHubApp
//
//  Created by bruno on feature/liked-clean-architecture.
//

import Foundation

/**
 * Domain state for the Liked feature business logic.
 *
 * This represents the current state of the Liked domain,
 * containing all data and status information needed by the business logic.
 */
struct LikedDomainState: Equatable {
    /// Movies that the user has liked
    var likedMovies: [Movie]

    /// Current loading state
    var isLoading: Bool

    /// Current error state
    var error: String?

    /// Default initial state
    static let initial = LikedDomainState(
        likedMovies: [],
        isLoading: false,
        error: nil
    )
}
