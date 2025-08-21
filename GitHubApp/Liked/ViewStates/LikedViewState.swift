//
//  LikedViewState.swift
//  GitHubApp
//
//  Created by bruno on feature/liked-clean-architecture.
//

import Foundation

/**
 * High-level UI state for the Liked view.
 */
enum LikedViewState: Equatable {
    /// Data is currently loading
    case loading
    /// Data loaded successfully with associated payload
    case success(LikedDataViewState)
    /// An error occurred with a message to display
    case error(String)
}
