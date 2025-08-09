//
//  HomeViewState.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import Foundation

/**
 * High-level UI state for the Home view.
 */
enum HomeViewState: Equatable {
    /// Data is currently loading
    case loading
    /// Data loaded successfully with associated payload
    case success(HomeDataViewState)
    /// An error occurred with a message to display
    case error(String)
}
