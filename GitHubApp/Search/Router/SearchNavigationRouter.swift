//
//  SearchNavigationRouter.swift
//  GitHubApp
//
//  Created by Claude Code
//

import EntropyCore
import SwiftUI
import UIKit

/**
 * Router for Search module navigation.
 *
 * Supports both SwiftUI navigation via Coordinator and UIKit fallback.
 *
 * @MainActor ensures all navigation operations happen on the main thread.
 */
@MainActor
final class SearchNavigationRouter: NavigationRouter, Equatable {
    /// Optional UIKit navigation controller for fallback navigation
    /// nonisolated(unsafe) allows identity comparison in Equatable conformance
    nonisolated(unsafe) weak var navigation: UINavigationController?
    /// Optional SwiftUI coordinator for declarative navigation
    /// nonisolated(unsafe) allows identity comparison in Equatable conformance
    private nonisolated(unsafe) weak var coordinator: Coordinator?
    /// Service locator for dependency injection
    private let serviceLocator: ServiceLocator?

    /// Create a router with optional coordinator reference
    init(coordinator: Coordinator? = nil, serviceLocator: ServiceLocator? = nil) {
        self.coordinator = coordinator
        self.serviceLocator = serviceLocator ?? coordinator?.serviceLocator
    }

    /**
     * Handle navigation events originating in SearchView.
     *
     * - Parameter navigationEvent: The event to route
     */
    func route(navigationEvent: SearchNavigationEvent) {
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

extension SearchNavigationRouter {
    /// Compare routers by their underlying navigation/coordinator references
    nonisolated static func == (lhs: SearchNavigationRouter, rhs: SearchNavigationRouter) -> Bool {
        lhs.navigation === rhs.navigation && lhs.coordinator === rhs.coordinator
    }
}
