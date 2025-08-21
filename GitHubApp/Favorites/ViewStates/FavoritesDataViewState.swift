//
//  FavoritesDataViewState.swift
//  GitHubApp
//
//  Created by bruno on feature/liked-clean-architecture.
//

import Foundation

/**
 * Data payload used by FavoritesView in the success state.
 *
 * Contains all the data needed by the view to render successfully.
 */
struct FavoritesDataViewState: Equatable {
    /// Title to display in the Favorites view
    var title: String

    /// Movies that are currently favorited by the user
    var favoriteMovies: [Movie]

    /// Whether the list is empty
    var isEmpty: Bool {
        favoriteMovies.isEmpty
    }

    /// Number of favorite movies
    var moviesCount: Int {
        favoriteMovies.count
    }
}
