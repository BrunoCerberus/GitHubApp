//
//  MovieDetailsViewStateReducing.swift
//  GitHubApp
//
//  Created by Claude Code
//

import Foundation

/**
 * Protocol for reducing domain state to view state.
 *
 * This protocol defines the contract for converting MovieDetailsDomainState
 * into MovieDetailsViewState, maintaining separation between domain and view concerns.
 */
protocol MovieDetailsViewStateReducing {
    /**
     * Reduces MovieDetailsDomainState to MovieDetailsViewState.
     *
     * - Parameter domainState: The current domain state
     * - Returns: The corresponding view state
     */
    func reduce(_ domainState: MovieDetailsDomainState) -> MovieDetailsViewState
}

/**
 * Default implementation of MovieDetailsViewStateReducing.
 *
 * This reducer converts domain state into appropriate view state,
 * handling loading, success, and error states appropriately.
 */
struct MovieDetailsViewStateReducer: MovieDetailsViewStateReducing {
    /**
     * Reduces MovieDetailsDomainState to MovieDetailsViewState.
     *
     * The reduction logic follows a strict state priority order:
     * 1. Error state (critical issues must be shown to user)
     * 2. Loading state (user feedback during operations)
     * 3. Success state (normal operation with data)
     *
     * - Parameter domainState: The current domain state
     * - Returns: The corresponding view state
     */
    func reduce(_ domainState: MovieDetailsDomainState) -> MovieDetailsViewState {
        // PRIORITY 1: Error State
        if let error = domainState.error {
            return .error(error)
        }

        // PRIORITY 2: Loading State
        if domainState.isLoading {
            return .loading
        }

        // PRIORITY 3: Success State
        let dataViewState = MovieDetailsDataViewState(
            movie: domainState.movie,
            credits: domainState.credits,
            reviews: domainState.reviews,
            favoriteMovies: domainState.favoriteMovies
        )
        return .success(dataViewState)
    }
}
