//
//  SearchDataViewState.swift
//  GitHubApp
//
//  Created by Claude Code
//

import Foundation

/**
 * Data payload used by SearchView in the success state.
 *
 * Contains all the data needed by the view to render successfully.
 */
struct SearchDataViewState: Equatable {
    /// Movies to display in the search results
    var movies: [Movie]

    /// Movies that are currently liked by the user
    var favoriteMovies: [Movie]

    /// Current search query
    var searchQuery: String?
}
