//
//  LikedDomainAction.swift
//  GitHubApp
//
//  Created by bruno on feature/liked-clean-architecture.
//

import Foundation

/**
 * Domain actions for the Liked feature business logic.
 *
 * These actions represent the business operations that can be performed
 * within the Liked domain, independent of UI concerns.
 */
enum LikedDomainAction: Equatable {
    case loadLikedMovies
    case toggleMovieLike(Movie)
    case clearAllLikedMovies
    case refreshLikedMovies
}
