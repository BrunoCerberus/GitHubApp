//
//  Coordinator.swift
//  GitHubApp
//
//  Created by bruno on 14/08/23.
//

import SwiftUI

/**
 * Protocol for coordinator-like objects that can handle navigation.
 */
protocol CoordinatorProtocol: AnyObject {
    func push(page: Page)
}

/**
 * Represents navigable destinations in the app.
 */
public enum Page: Hashable {
    case home
    case search
    case detail(Movie)
}

/**
 * Navigation coordinator that builds views and manages navigation path.
 *
 * Holds shared ViewModels and routes between SwiftUI pages.
 *
 * @MainActor ensures all navigation and ViewModel initialization happens on the main thread.
 */
@MainActor
final class Coordinator: ObservableObject, CoordinatorProtocol {
    /// Current navigation path for the primary stack
    @Published var path: NavigationPath = .init()

    /// Service locator for dependency injection
    let serviceLocator: ServiceLocator

    /// Shared HomeViewModel instance
    lazy var homeViewModel: HomeViewModel = .init(serviceLocator: serviceLocator)

    /// Shared SearchViewModel instance (dedicated for search functionality)
    lazy var searchViewModel: SearchViewModel = .init(serviceLocator: serviceLocator)

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
        Logger.shared.ui("Coordinator deallocated", level: .debug)
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
        case .search:
            SearchView(router: SearchNavigationRouter(coordinator: self), viewModel: searchViewModel, serviceLocator: serviceLocator)
        case let .detail(movie):
            let viewModel = MovieDetailsViewModel(movie: movie, serviceLocator: serviceLocator)
            MovieDetailsView(router: MovieDetailsNavigationRouter(coordinator: self), viewModel: viewModel)
        }
    }
}
