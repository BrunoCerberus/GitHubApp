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

    lazy var homeViewModel: HomeViewModel = {
        // Use mock service when running tests to avoid real network requests
        #if DEBUG
            if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
                return HomeViewModel(service: MockService())
            }
        #endif
        return HomeViewModel()
    }()

    lazy var likedMoviesViewModel: LikedMoviesViewModel = .init()

    init() {
        // No longer need to connect the ViewModels
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
            let viewModel: MovieDetailsViewModel = {
                // Use mock service when running tests to avoid real network requests
                #if DEBUG
                    if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
                        return MovieDetailsViewModel(movie: movie, service: MockService())
                    }
                #endif
                return MovieDetailsViewModel(movie: movie)
            }()
            MovieDetailsView(viewModel: viewModel)
        }
    }
}
