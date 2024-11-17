//
//  HomeNavigationRouter.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import UIKit
import SwiftUI
import EntropyCore

final class HomeNavigationRouter: NavigationRouter {
    weak var navigation: UINavigationController?

    func route(navigationEvent: HomeNavigationEvent) {
        switch navigationEvent {
        case let .detail(movie):
            let controller = MovieDetailsHostingController(movie: movie)
            navigation?.pushViewController(controller, animated: true)
        }
    }
}
