//
//  HomeViewStateReducing.swift
//  GitHubApp
//
//  Created by bruno on feature/home-clean-architecture.
//

import Foundation

/**
 * Protocol for reducing domain state to view state.
 *
 * This protocol defines the contract for converting HomeDomainState
 * into HomeViewState, maintaining separation between domain and view concerns.
 */
protocol HomeViewStateReducing {
    /**
     * Reduces HomeDomainState to HomeViewState.
     *
     * - Parameter domainState: The current domain state
     * - Returns: The corresponding view state
     */
    func reduce(_ domainState: HomeDomainState) -> HomeViewState
}

/**
 * Default implementation of HomeViewStateReducing.
 *
 * This reducer converts domain state into appropriate view state,
 * handling loading, success, and error states appropriately.
 */
struct HomeViewStateReducer: HomeViewStateReducing {
    /**
     * Reduces HomeDomainState to HomeViewState.
     *
     * The reduction logic follows a strict state priority order:
     * 1. Error state (critical issues must be shown to user)
     * 2. Loading state (user feedback during operations)
     * 3. Success state (normal operation with data)
     *
     * ## State Priority Rules
     *
     * ### Priority 1: Error State
     * - Shows error messages for failed operations
     *
     * ### Priority 2: Loading State
     * - Shows full-screen loading indicator during fetch operations
     *
     * ### Priority 3: Success State
     * - Always returned when no error/loading conditions exist
     * - Includes both populated and empty data states
     *
     * - Parameter domainState: The current domain state
     * - Returns: The corresponding view state
     *
     * - SeeAlso: `ARCHITECTURE_PATTERNS.md` for detailed explanation of ViewStateReducing pattern
     */
    func reduce(_ domainState: HomeDomainState) -> HomeViewState {
        // PRIORITY 1: Error State
        if let error = domainState.error {
            return .error(error)
        }

        // PRIORITY 2: Loading State
        if domainState.isLoading {
            return .loading
        }

        // PRIORITY 3: Success State
        let dataViewState = HomeDataViewState(
            title: domainState.searchQuery != nil ? "Search Results" : "Upcoming Movies",
            movies: domainState.movies,
            favoriteMovies: domainState.favoriteMovies,
            searchQuery: domainState.searchQuery
        )
        return .success(dataViewState)
    }
}
