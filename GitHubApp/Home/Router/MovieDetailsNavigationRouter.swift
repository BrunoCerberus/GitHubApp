//
//  MovieDetailsNavigationRouter.swift
//  GitHubApp
//
//  Created by Claude Code
//

@preconcurrency import EntropyCore
import SwiftUI
import UIKit

/**
 * Router for MovieDetails module navigation.
 *
 * Supports both SwiftUI navigation via Coordinator and UIKit fallback.
 *
 * @MainActor ensures all navigation operations happen on the main thread.
 */
@MainActor
final class MovieDetailsNavigationRouter: NavigationRouter, Equatable {
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
     * Handle navigation events originating in MovieDetailsView.
     *
     * - Parameter navigationEvent: The event to route
     */
    func route(navigationEvent: MovieDetailsNavigationEvent) {
        switch navigationEvent {
        case .back:
            if let navigation {
                // Use UIKit navigation
                navigation.popViewController(animated: true)
            }
            // For SwiftUI navigation, the back button is automatically provided by NavigationStack
        }
    }
}

extension MovieDetailsNavigationRouter {
    /// Compare routers by their underlying navigation/coordinator references
    static func == (lhs: MovieDetailsNavigationRouter, rhs: MovieDetailsNavigationRouter) -> Bool {
        lhs.navigation === rhs.navigation && lhs.coordinator === rhs.coordinator
    }
}
