//
//  HomeDataViewState.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import Foundation

/**
 * Data payload used by HomeView in the success state.
 *
 * Contains all the data needed by the view to render successfully.
 */
struct HomeDataViewState: Equatable {
    /// Title to display in the Home view
    var title: String

    /// Movies to display in the list
    var movies: [Movie]

    /// Movies that are currently liked by the user
    var favoriteMovies: [Movie]

    /// Current search query (if any)
    var searchQuery: String?
}
