//
//  FavoritesViewStateReducing.swift
//  GitHubApp
//
//  Created by bruno on feature/liked-clean-architecture.
//

import Foundation

/**
 * Protocol for reducing domain state to view state in the Favorites feature.
 */
protocol FavoritesViewStateReducing {
    /// Convert domain state to view state
    func reduce(_ domainState: FavoritesDomainState) -> FavoritesViewState
}

/**
 * Default implementation of FavoritesViewStateReducing.
 *
 * This reducer converts the domain state (business logic state) into
 * view state (UI-specific state) for the Favorites feature.
 */
struct FavoritesViewStateReducer: FavoritesViewStateReducing {
    /**
     * Convert domain state to view state.
     *
     * This method transforms the business logic state into a format
     * that is optimized for UI consumption.
     *
     * - Parameter domainState: The current domain state
     * - Returns: The corresponding view state
     */
    func reduce(_ domainState: FavoritesDomainState) -> FavoritesViewState {
        // Handle error state first
        if let error = domainState.error {
            return .error(error)
        }

        // Handle loading state
        if domainState.isLoading {
            return .loading
        }

        // Handle success state with data
        let dataViewState = FavoritesDataViewState(
            title: generateTitle(for: domainState.favoriteMovies),
            favoriteMovies: domainState.favoriteMovies
        )

        return .success(dataViewState)
    }

    // MARK: - Private Helper Methods

    /**
     * Generate an appropriate title based on the number of favorite movies.
     *
     * - Parameter favoriteMovies: Array of favorite movies
     * - Returns: Localized title string
     */
    private func generateTitle(for favoriteMovies: [Movie]) -> String {
        if favoriteMovies.isEmpty {
            return NSLocalizedString("favorites_no_movies_title", comment: "Title when no movies are favorited")
        } else {
            let format = NSLocalizedString("favorites_movies_count_title", comment: "Title showing count of favorite movies")
            return String.localizedStringWithFormat(format, favoriteMovies.count)
        }
    }
}
