//
//  MovieDetailsDataViewState.swift
//  GitHubApp
//
//  Created by Claude Code
//

import Foundation

/**
 * Data payload used by MovieDetailsView in the success state.
 *
 * Contains all the data needed by the view to render successfully.
 */
struct MovieDetailsDataViewState: Equatable {
    /// The movie being displayed
    var movie: Movie

    /// Cast and crew members for the movie
    var credits: [MovieCastMember]

    /// User and critic reviews for the movie
    var reviews: [MovieReview]

    /// Movies that are currently favorited by the user
    var favoriteMovies: [Movie]
}
