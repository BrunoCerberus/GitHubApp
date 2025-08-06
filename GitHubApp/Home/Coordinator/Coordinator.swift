//
//  Coordinator.swift
//  GitHubApp
//
//  Created by bruno on 14/08/23.
//

import SwiftUI

enum Page: Hashable {
    case home
    case detail(Movie)
}

final class Coordinator: ObservableObject {
    @Published var path: NavigationPath = .init()

    /// Service locator for dependency injection
    private let serviceLocator: ServiceLocator

    lazy var homeViewModel: HomeViewModel = .init(serviceLocator: serviceLocator)

    lazy var likedMoviesViewModel: LikedMoviesViewModel = .init()

    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }

    deinit {
        // Ensure proper cleanup
        print("Coordinator deallocated")
    }

    func push(page: Page) {
        path.append(page)
    }

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
