//
//  FavoritesViewEvent.swift
//  GitHubApp
//
//  Created by bruno on feature/liked-clean-architecture.
//

import Foundation

/**
 * User/intention events originating from the Favorites view.
 */
enum FavoritesViewEvent: Equatable {
    case loadFavoriteMovies
    case toggleFavorite(Movie)
    case clearAllFavoriteMovies
    case refreshFavoriteMovies
}
