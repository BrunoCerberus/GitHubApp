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
     * The reduction logic prioritizes states in this order:
     * 1. Error state (if error exists)
     * 2. Loading state (if currently loading)
     * 3. Success state (with current data)
     *
     * - Parameter domainState: The current domain state
     * - Returns: The corresponding view state
     */
    func reduce(_ domainState: HomeDomainState) -> HomeViewState {
        // Handle error state first
        if let error = domainState.error {
            return .error(error)
        }

        // Handle loading state
        if domainState.isLoading {
            return .loading
        }

        // Handle success state with data
        let dataViewState = HomeDataViewState(
            title: domainState.searchQuery != nil ? "Search Results" : "Upcoming Movies",
            movies: domainState.movies,
            favoriteMovies: domainState.favoriteMovies,
            searchQuery: domainState.searchQuery
        )
        return .success(dataViewState)
    }
}
