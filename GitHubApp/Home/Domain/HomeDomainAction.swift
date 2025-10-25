//
//  HomeDomainAction.swift
//  GitHubApp
//
//  Created by bruno on feature/home-clean-architecture.
//

import Foundation

/**
 * Domain actions for the Home feature business logic.
 *
 * These actions represent the business operations that can be performed
 * within the Home domain, independent of UI concerns.
 */
enum HomeDomainAction: Equatable {
    case fetchUpcomingMovies
    case searchMovies(String)
    case toggleMovieFavorite(Movie)
    case loadPersistedFavoriteMovies
}
