//
//  HomeNavigationRouter.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import EntropyCore
import SwiftUI
import UIKit

/**
 * Router for Home module navigation.
 *
 * Supports both SwiftUI navigation via Coordinator and UIKit fallback.
 *
 * @MainActor ensures all navigation operations happen on the main thread.
 */
@MainActor
final class HomeNavigationRouter: NavigationRouter, Equatable {
    /// Optional UIKit navigation controller for fallback navigation
    weak var navigation: UINavigationController?
    /// Optional SwiftUI coordinator for declarative navigation
    private weak var coordinator: Coordinator?
    /// Service locator for dependency injection
    private let serviceLocator: ServiceLocator?

    /// Create a router with optional coordinator reference
    init(coordinator: Coordinator? = nil, serviceLocator: ServiceLocator? = nil) {
        self.coordinator = coordinator
        self.serviceLocator = serviceLocator ?? coordinator?.serviceLocator
    }

    /**
     * Handle navigation events originating in HomeView.
     *
     * - Parameter navigationEvent: The event to route
     */
    func route(navigationEvent: HomeNavigationEvent) {
        switch navigationEvent {
        case let .detail(movie):
            if let coordinator {
                // Use SwiftUI navigation
                coordinator.push(page: .detail(movie))
            } else if let navigation, let serviceLocator {
                // Fallback to UIKit navigation
                let controller = MovieDetailsHostingController(movie: movie, serviceLocator: serviceLocator)
                navigation.pushViewController(controller, animated: true)
            }
        }
    }
}

extension HomeNavigationRouter {
    /// Compare routers by their underlying navigation/coordinator references
    static func == (lhs: HomeNavigationRouter, rhs: HomeNavigationRouter) -> Bool {
        lhs.navigation === rhs.navigation && lhs.coordinator === rhs.coordinator
    }
}
