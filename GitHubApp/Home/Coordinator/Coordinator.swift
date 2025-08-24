//
//  Coordinator.swift
//  GitHubApp
//
//  Created by bruno on 14/08/23.
//

import SwiftUI

/**
 * Represents navigable destinations in the app.
 */
public enum Page: Hashable {
    case home
    case detail(Movie)
}

/**
 * Navigation coordinator that builds views and manages navigation path.
 *
 * Holds shared ViewModels and routes between SwiftUI pages.
 */
final class Coordinator: ObservableObject, CoordinatorProtocol {
    /// Current navigation path for the primary stack
    @Published var path: NavigationPath = .init()

    /// Service locator for dependency injection
    private let serviceLocator: ServiceLocator

    /// Shared HomeViewModel instance
    lazy var homeViewModel: HomeViewModel = {
        do {
            return try .init(serviceLocator: serviceLocator)
        } catch {
            fatalError("Failed to initialize HomeViewModel: \(error)")
        }
    }()

    /// Shared FavoritesMoviesViewModel instance
    lazy var favoriteMoviesViewModel: FavoritesMoviesViewModel = .init(serviceLocator: serviceLocator)

    /// Shared SettingsViewModel instance
    lazy var settingsViewModel: SettingsViewModel = .init(serviceLocator: serviceLocator)

    /// Create a coordinator with a configured ServiceLocator
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }

    deinit {
        // Ensure proper cleanup
        #if DEBUG
            print("Coordinator deallocated")
        #endif
    }

    /**
     * Push a destination onto the navigation stack.
     *
     * - Parameter page: The destination to navigate to
     */
    func push(page: Page) {
        path.append(page)
    }

    /**
     * Build the SwiftUI view for a destination.
     *
     * - Parameter page: The destination to render
     * - Returns: A type-erased view for the destination
     */
    @ViewBuilder
    func build(page: Page) -> some View {
        switch page {
        case .home:
            HomeView(router: HomeNavigationRouter(coordinator: self), viewModel: homeViewModel)
        case let .detail(movie):
            let viewModel = MovieDetailsViewModel(movie: movie, serviceLocator: serviceLocator)
            MovieDetailsView(viewModel: viewModel)
        }
    }
}
