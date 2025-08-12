//
//  DeeplinkRouter.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import Foundation
import UIKit

/**
 * Routes deeplinks to appropriate navigation actions.
 *
 * This class takes parsed deeplinks and converts them to navigation
 * events that can be processed by the app's existing routing system.
 */
final class DeeplinkRouter {
    /// The deeplink manager for parsing URLs
    private let deeplinkManager: DeeplinkManager

    /// The coordinator for SwiftUI navigation
    private weak var coordinator: Coordinator?

    /// The UIKit navigation controller for fallback navigation
    private weak var navigationController: UINavigationController?

    /// Initialize with required dependencies
    /// - Parameters:
    ///   - deeplinkManager: The deeplink manager instance
    ///   - coordinator: The SwiftUI coordinator (optional)
    ///   - navigationController: The UIKit navigation controller (optional)
    init(
        deeplinkManager: DeeplinkManager,
        coordinator: Coordinator? = nil,
        navigationController: UINavigationController? = nil
    ) {
        self.deeplinkManager = deeplinkManager
        self.coordinator = coordinator
        self.navigationController = navigationController
    }

    /// Process a deeplink URL and navigate accordingly
    /// - Parameter url: The URL to process
    /// - Returns: True if the deeplink was successfully processed
    @discardableResult
    func process(url: URL) -> Bool {
        let deeplinkType = deeplinkManager.parse(url: url)

        switch deeplinkType {
        case let .movieDetails(movieId):
            return navigateToMovieDetails(movieId: movieId)

        case .unknown:
            return false
        }
    }

    /// Navigate to movie details using the available navigation methods
    /// - Parameter movieId: The movie ID to navigate to
    /// - Returns: True if navigation was successful
    private func navigateToMovieDetails(movieId: Int) -> Bool {
        // First try to use the coordinator if available
        if let coordinator {
            // We need to create a Movie object with the ID
            // For now, we'll create a minimal Movie object
            let movie = Movie(
                id: movieId,
                title: "", // Will be loaded by the view model
                overview: "",
                posterPath: nil
            )

            coordinator.push(page: .detail(movie))
            return true
        }

        // Fallback to UIKit navigation if coordinator is not available
        if let navigationController {
            // Create a minimal Movie object and hosting controller
            let movie = Movie(
                id: movieId,
                title: "",
                overview: "",
                posterPath: nil
            )

            // Note: This would need a ServiceLocator instance
            // For now, we'll return false to indicate we need the coordinator
            return false
        }

        return false
    }

    /// Update the coordinator reference
    /// - Parameter coordinator: The new coordinator instance
    func updateCoordinator(_ coordinator: Coordinator) {
        self.coordinator = coordinator
    }

    /// Update the navigation controller reference
    /// - Parameter navigationController: The new navigation controller instance
    func updateNavigationController(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}
