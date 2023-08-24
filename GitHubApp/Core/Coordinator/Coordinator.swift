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

class Coordinator: ObservableObject {
    @Published var path = NavigationPath()

    lazy var homeViewModel = HomeViewModel()

    func push(page: Page) {
        path.append(page)
    }

    @ViewBuilder
    func build(page: Page) -> some View {
        switch page {
        case .home:
            HomeView(router: HomeNavigationRouter(), viewModel: homeViewModel)
        case let .detail(movie):
            let viewModel = MovieDetailsViewModel(movie: movie)
            MovieDetailsView(viewModel: viewModel)
        }
    }
}
