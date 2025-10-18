//
//  SearchViewStateReducing.swift
//  GitHubApp
//
//  Created by Claude Code
//

import Foundation

/**
 * Protocol for reducing domain state to view state.
 *
 * This protocol defines the contract for converting SearchDomainState
 * into SearchViewState, maintaining separation between domain and view concerns.
 */
protocol SearchViewStateReducing {
    /**
     * Reduces SearchDomainState to SearchViewState.
     *
     * - Parameter domainState: The current domain state
     * - Returns: The corresponding view state
     */
    func reduce(_ domainState: SearchDomainState) -> SearchViewState
}

/**
 * Default implementation of SearchViewStateReducing.
 *
 * This reducer converts domain state into appropriate view state,
 * handling loading, success, and error states appropriately.
 */
struct SearchViewStateReducer: SearchViewStateReducing {
    /**
     * Reduces SearchDomainState to SearchViewState.
     *
     * The reduction logic prioritizes states in this order:
     * 1. Error state (if error exists)
     * 2. Loading state (if currently loading)
     * 3. Success state (with current data)
     *
     * - Parameter domainState: The current domain state
     * - Returns: The corresponding view state
     */
    func reduce(_ domainState: SearchDomainState) -> SearchViewState {
        // Handle error state first (but only if not loading more)
        if let error = domainState.error, !domainState.isLoadingMore {
            return .error(error)
        }

        // Handle initial loading state (not loading more)
        if domainState.isLoading {
            return .loading
        }

        // Handle success state with data (including while loading more)
        let dataViewState = SearchDataViewState(
            movies: domainState.movies,
            favoriteMovies: domainState.favoriteMovies,
            searchQuery: domainState.searchQuery,
            isLoadingMore: domainState.isLoadingMore
        )
        return .success(dataViewState)
    }
}
