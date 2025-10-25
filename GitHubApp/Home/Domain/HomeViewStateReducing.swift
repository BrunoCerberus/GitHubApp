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
     * 2. Loading state (user feedback during initial operations)
     * 3. Success state (normal operation with data)
     *
     * ## State Priority Rules
     *
     * ### Priority 1: Error State
     * - Shows error messages for failed operations
     * - **Exception**: Skips error during pagination (`isLoadingMore == true`)
     * - **Reason**: Preserves existing content when "load more" fails
     * - **UX Benefit**: Users can still see current movies instead of error screen
     *
     * ### Priority 2: Loading State
     * - Shows full-screen loading indicator during initial fetch
     * - Only applies when `isLoading == true` (not during pagination)
     * - Different from pagination loading which shows at bottom of list
     *
     * ### Priority 3: Success State
     * - Always returned when no error/loading conditions exist
     * - Includes both populated and empty data states
     * - Handles pagination loading indicator via `isLoadingMore` flag
     *
     * - Parameter domainState: The current domain state
     * - Returns: The corresponding view state
     *
     * - SeeAlso: `ARCHITECTURE_PATTERNS.md` for detailed explanation of ViewStateReducing pattern
     */
    func reduce(_ domainState: HomeDomainState) -> HomeViewState {
        // PRIORITY 1: Error State
        // Skip error during pagination to preserve existing content
        // This allows showing current movies even when "load more" fails
        if let error = domainState.error, !domainState.isLoadingMore {
            return .error(error)
        }

        // PRIORITY 2: Loading State
        // Show full-screen loading only during initial fetch
        // Pagination uses isLoadingMore (handled in success state)
        if domainState.isLoading {
            return .loading
        }

        // PRIORITY 3: Success State
        // Show content (even if empty) with optional pagination loading
        // isLoadingMore indicates loading spinner at bottom of list
        let dataViewState = HomeDataViewState(
            title: domainState.searchQuery != nil ? "Search Results" : "Upcoming Movies",
            movies: domainState.movies,
            favoriteMovies: domainState.favoriteMovies,
            searchQuery: domainState.searchQuery,
            isLoadingMore: domainState.isLoadingMore
        )
        return .success(dataViewState)
    }
}
