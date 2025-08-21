//
//  FavoritesDomainAction.swift
//  GitHubApp
//
//  Created by bruno on feature/liked-clean-architecture.
//

import Foundation

/**
 * Domain actions for the Favorites feature business logic.
 *
 * These actions represent the business operations that can be performed
 * within the Favorites domain, independent of UI concerns.
 */
enum FavoritesDomainAction: Equatable {
    case loadFavoriteMovies
    case toggleMovieFavorite(Movie)
    case clearAllFavoriteMovies
    case refreshFavoriteMovies
}
