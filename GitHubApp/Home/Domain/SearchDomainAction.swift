//
//  SearchDomainAction.swift
//  GitHubApp
//
//  Created by Claude Code
//

import Foundation

/**
 * Domain actions for the Search feature business logic.
 *
 * These actions represent the business operations that can be performed
 * within the Search domain, independent of UI concerns.
 */
enum SearchDomainAction: Equatable {
    case searchMovies(String)
    case toggleMovieFavorite(Movie)
    case loadPersistedFavoriteMovies
}
