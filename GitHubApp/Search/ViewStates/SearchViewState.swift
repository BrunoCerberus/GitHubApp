//
//  SearchViewState.swift
//  GitHubApp
//
//  Created by Claude Code
//

import Foundation

/**
 * High-level UI state for the Search view.
 */
enum SearchViewState: Equatable {
    /// Data is currently loading
    case loading
    /// Data loaded successfully with associated payload
    case success(SearchDataViewState)
    /// An error occurred with a message to display
    case error(String)
}
