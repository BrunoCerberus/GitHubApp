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
    @Published var path = NavigationPath()

    lazy var homeViewModel = HomeViewModel()

    func push(page: Page) {
        path.append(page)
    }

    @ViewBuilder
    func build(page: Page) -> some View {
        switch page {
        case .home:
            HomeView(router: HomeNavigationRouter(coordinator: self), viewModel: homeViewModel)
        case let .detail(movie):
            let viewModel = MovieDetailsViewModel(movie: movie)
            MovieDetailsView(viewModel: viewModel)
        }
    }
}
