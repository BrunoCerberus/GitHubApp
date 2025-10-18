//
//  SearchDomainState.swift
//  GitHubApp
//
//  Created by Claude Code
//

import Foundation

/**
 * Domain state for the Search feature business logic.
 *
 * This represents the current state of the Search domain,
 * containing all data and status information needed by the business logic.
 */
struct SearchDomainState: Equatable {
    /// Current list of movies (search results)
    var movies: [Movie]

    /// Movies that the user has favorited
    var favoriteMovies: [Movie]

    /// Current loading state
    var isLoading: Bool

    /// Current error state
    var error: String?

    /// Current search query
    var searchQuery: String?

    /// Current page number for pagination
    var currentPage: Int

    /// Total number of pages available
    var totalPages: Int

    /// Flag indicating if more pages can be loaded
    var hasMorePages: Bool {
        currentPage < totalPages
    }

    /// Flag indicating if pagination is in progress
    var isLoadingMore: Bool

    /// Default initial state
    static let initial = SearchDomainState(
        movies: [],
        favoriteMovies: [],
        isLoading: false,
        error: nil,
        searchQuery: nil,
        currentPage: 0,
        totalPages: 0,
        isLoadingMore: false
    )
}
