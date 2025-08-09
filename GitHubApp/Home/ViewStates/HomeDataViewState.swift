//
//  HomeDataViewState.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import Foundation

/**
 * Data payload used by HomeView in the success state.
 *
 * Extend with additional fields as needed.
 */
struct HomeDataViewState: Equatable {
    /// Title to display in the Home view
    var title: String
}
