//
//  MovieDetailsViewState.swift
//  GitHubApp
//
//  Created by Claude Code
//

import Foundation

/**
 * High-level UI state for the MovieDetails view.
 */
enum MovieDetailsViewState: Equatable {
    /// Data is currently loading
    case loading
    /// Data loaded successfully with associated payload
    case success(MovieDetailsDataViewState)
    /// An error occurred with a message to display
    case error(String)
}
