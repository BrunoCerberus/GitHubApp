//
//  MovieDetailsDomainAction.swift
//  GitHubApp
//
//  Created by Claude Code
//

import Foundation

/**
 * Domain actions for the MovieDetails feature business logic.
 *
 * These actions represent the business operations that can be performed
 * within the MovieDetails domain, independent of UI concerns.
 */
enum MovieDetailsDomainAction: Equatable {
    case fetchMovieDetails
    case toggleMovieFavorite(Movie)
}
