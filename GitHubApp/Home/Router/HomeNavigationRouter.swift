//
//  HomeNavigationRouter.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import UIKit
import SwiftUI
import EntropyCore

final class HomeNavigationRouter: NavigationRouter, Equatable {
    weak var navigation: UINavigationController?
    private weak var coordinator: Coordinator?

    init(coordinator: Coordinator? = nil) {
        self.coordinator = coordinator
    }

    func route(navigationEvent: HomeNavigationEvent) {
        switch navigationEvent {
        case let .detail(movie):
            if let coordinator = coordinator {
                // Use SwiftUI navigation
                coordinator.push(page: .detail(movie))
            } else if let navigation = navigation {
                // Fallback to UIKit navigation
                let controller = MovieDetailsHostingController(movie: movie)
                navigation.pushViewController(controller, animated: true)
            }
        }
    }
}

extension HomeNavigationRouter {
    static func == (lhs: HomeNavigationRouter, rhs: HomeNavigationRouter) -> Bool {
        return lhs.navigation === rhs.navigation && lhs.coordinator === rhs.coordinator
    }
}
