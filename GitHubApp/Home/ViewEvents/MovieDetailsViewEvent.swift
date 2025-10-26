//
//  MovieDetailsViewEvent.swift
//  GitHubApp
//
//  Created by Claude Code
//

import Foundation

/**
 * User/intention events originating from the MovieDetails view.
 */
enum MovieDetailsViewEvent: Equatable {
    case fetchData
    case toggleFavorite(Movie)
}
