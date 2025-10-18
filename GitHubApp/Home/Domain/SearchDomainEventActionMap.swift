//
//  SearchDomainEventActionMap.swift
//  GitHubApp
//
//  Created by Claude Code
//

import Foundation

/**
 * Maps SearchViewEvent to SearchDomainAction.
 *
 * This mapper is responsible for translating UI events into domain actions,
 * maintaining separation between the view layer and domain layer concerns.
 */
enum SearchDomainEventActionMap {
    /**
     * Maps a SearchViewEvent to its corresponding SearchDomainAction.
     *
     * - Parameter event: The view event to map
     * - Returns: The corresponding domain action
     */
    static func map(_ event: SearchViewEvent) -> SearchDomainAction {
        switch event {
        case let .searchMovies(query):
            .searchMovies(query)
        case let .toggleFavorite(movie):
            .toggleMovieFavorite(movie)
        case .loadFavoriteMovies:
            .loadPersistedFavoriteMovies
        case .loadMoreMovies:
            .loadMoreMovies
        }
    }
}
