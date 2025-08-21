//
//  LikedViewStateReducing.swift
//  GitHubApp
//
//  Created by bruno on feature/liked-clean-architecture.
//

import Foundation

/**
 * Protocol for reducing domain state to view state in the Liked feature.
 */
protocol LikedViewStateReducing {
    /// Convert domain state to view state
    func reduce(_ domainState: LikedDomainState) -> LikedViewState
}

/**
 * Default implementation of LikedViewStateReducing.
 *
 * This reducer converts the domain state (business logic state) into
 * view state (UI-specific state) for the Liked feature.
 */
struct LikedViewStateReducer: LikedViewStateReducing {
    /**
     * Convert domain state to view state.
     *
     * This method transforms the business logic state into a format
     * that is optimized for UI consumption.
     *
     * - Parameter domainState: The current domain state
     * - Returns: The corresponding view state
     */
    func reduce(_ domainState: LikedDomainState) -> LikedViewState {
        // Handle error state first
        if let error = domainState.error {
            return .error(error)
        }

        // Handle loading state
        if domainState.isLoading {
            return .loading
        }

        // Handle success state with data
        let dataViewState = LikedDataViewState(
            title: generateTitle(for: domainState.likedMovies),
            likedMovies: domainState.likedMovies
        )

        return .success(dataViewState)
    }

    // MARK: - Private Helper Methods

    /**
     * Generate an appropriate title based on the number of liked movies.
     *
     * - Parameter likedMovies: Array of liked movies
     * - Returns: Localized title string
     */
    private func generateTitle(for likedMovies: [Movie]) -> String {
        if likedMovies.isEmpty {
            return NSLocalizedString("liked_no_movies_title", comment: "Title when no movies are liked")
        } else {
            let format = NSLocalizedString("liked_movies_count_title", comment: "Title showing count of liked movies")
            return String.localizedStringWithFormat(format, likedMovies.count)
        }
    }
}
