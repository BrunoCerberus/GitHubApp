//
//  HomeDomainEventActionMap.swift
//  GitHubApp
//
//  Created by bruno on feature/home-clean-architecture.
//

import Foundation

/**
 * Maps HomeViewEvent to HomeDomainAction.
 *
 * This mapper is responsible for translating UI events into domain actions,
 * maintaining separation between the view layer and domain layer concerns.
 */
enum HomeDomainEventActionMap {
    /**
     * Maps a HomeViewEvent to its corresponding HomeDomainAction.
     *
     * - Parameter event: The view event to map
     * - Returns: The corresponding domain action
     */
    static func map(_ event: HomeViewEvent) -> HomeDomainAction {
        switch event {
        case .fetchData:
            .fetchUpcomingMovies
        case let .searchMovies(query):
            .searchMovies(query)
        case let .toggleLike(movie):
            .toggleMovieFavorite(movie)
        case .loadFavoriteMovies:
            .loadPersistedLikedMovies
        }
    }
}
