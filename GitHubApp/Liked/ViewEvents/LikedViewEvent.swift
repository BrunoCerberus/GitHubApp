//
//  LikedViewEvent.swift
//  GitHubApp
//
//  Created by bruno on feature/liked-clean-architecture.
//

import Foundation

/**
 * User/intention events originating from the Liked view.
 */
enum LikedViewEvent: Equatable {
    case loadLikedMovies
    case toggleLike(Movie)
    case clearAllLikedMovies
    case refreshLikedMovies
}
