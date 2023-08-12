//
//  HomeNavigationRouter.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import UIKit
import SwiftUI

final class HomeNavigationRouter: NavigationRouter {
    var navigation: UINavigationController?

    func route(navigationEvent: HomeNavigationEvent) {
        switch navigationEvent {
        case let .detail(movie):
            let vc = UIHostingController(rootView: MovieDetailsView(viewModel: MovieDetailsViewModel(movie: movie)))
            vc.title = movie.title
            navigation?.pushViewController(vc, animated: true)
        }
    }
}
