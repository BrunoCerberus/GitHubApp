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
