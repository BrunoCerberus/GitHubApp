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
     * Follows the same state priority pattern as HomeViewStateReducer:
     * 1. Error state (critical issues must be shown to user)
     * 2. Loading state (user feedback during initial search)
     * 3. Success state (search results or empty state)
     *
     * ## State Priority Rules
     *
     * ### Priority 1: Error State
     * - Shows error messages for failed search operations
     * - **Exception**: Skips error during pagination (`isLoadingMore == true`)
     * - **Reason**: Preserves existing search results when "load more" fails
     * - **UX Benefit**: Users keep their current results instead of seeing error screen
     *
     * ### Priority 2: Loading State
     * - Shows full-screen loading indicator during initial search
     * - Only applies when `isLoading == true` (not during pagination)
     * - Pagination loading shows at bottom of search results
     *
     * ### Priority 3: Success State
     * - Always returned when no error/loading conditions exist
     * - Includes search results, empty results, and idle states
     * - Handles pagination loading via `isLoadingMore` flag
     *
     * - Parameter domainState: The current domain state
     * - Returns: The corresponding view state
     *
     * - SeeAlso: `ARCHITECTURE_PATTERNS.md` for ViewStateReducing pattern details
     */
    func reduce(_ domainState: SearchDomainState) -> SearchViewState {
        // PRIORITY 1: Error State
        // Skip error during pagination to preserve existing search results
        if let error = domainState.error, !domainState.isLoadingMore {
            return .error(error)
        }

        // PRIORITY 2: Loading State
        // Show full-screen loading only during initial search
        if domainState.isLoading {
            return .loading
        }

        // PRIORITY 3: Success State
        // Show search results with optional pagination loading
        let dataViewState = SearchDataViewState(
            movies: domainState.movies,
            favoriteMovies: domainState.favoriteMovies,
            searchQuery: domainState.searchQuery,
            isLoadingMore: domainState.isLoadingMore
        )
        return .success(dataViewState)
    }
}
