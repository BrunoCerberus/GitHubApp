//
//  HomeViewState.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import Foundation

enum HomeViewState: Equatable {
    case loading
    case success(HomeDataViewState)
}
