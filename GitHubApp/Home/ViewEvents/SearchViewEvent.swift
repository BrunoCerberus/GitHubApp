//
//  SearchViewEvent.swift
//  GitHubApp
//
//  Created by Claude Code
//

import Foundation

/**
 * User/intention events originating from the Search view.
 */
enum SearchViewEvent: Equatable {
    case searchMovies(String)
    case toggleFavorite(Movie)
    case loadFavoriteMovies
    case loadMoreMovies
}
