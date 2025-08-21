//
//  LikedDataViewState.swift
//  GitHubApp
//
//  Created by bruno on feature/liked-clean-architecture.
//

import Foundation

/**
 * Data payload used by LikedView in the success state.
 *
 * Contains all the data needed by the view to render successfully.
 */
struct LikedDataViewState: Equatable {
    /// Title to display in the Liked view
    var title: String

    /// Movies that are currently liked by the user
    var likedMovies: [Movie]

    /// Whether the list is empty
    var isEmpty: Bool {
        likedMovies.isEmpty
    }

    /// Number of liked movies
    var moviesCount: Int {
        likedMovies.count
    }
}
