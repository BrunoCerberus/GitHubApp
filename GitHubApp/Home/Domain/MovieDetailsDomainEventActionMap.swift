//
//  MovieDetailsDomainEventActionMap.swift
//  GitHubApp
//
//  Created by Claude Code
//

import Foundation

/**
 * Maps MovieDetailsViewEvent to MovieDetailsDomainAction.
 *
 * This mapper is responsible for translating UI events into domain actions,
 * maintaining separation between the view layer and domain layer concerns.
 */
enum MovieDetailsDomainEventActionMap {
    /**
     * Maps a MovieDetailsViewEvent to its corresponding MovieDetailsDomainAction.
     *
     * - Parameter event: The view event to map
     * - Returns: The corresponding domain action
     */
    static func map(_ event: MovieDetailsViewEvent) -> MovieDetailsDomainAction {
        switch event {
        case .fetchData:
            .fetchMovieDetails
        case let .toggleFavorite(movie):
            .toggleMovieFavorite(movie)
        }
    }
}
