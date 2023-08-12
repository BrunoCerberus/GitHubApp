//
//  HomeNavigationRouter.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import UIKit
import SwiftUI

final class HomeNavigationRouter: NavigationRouter {
    weak var navigation: UINavigationController?

    func route(navigationEvent: HomeNavigationEvent) {
        switch navigationEvent {
        case let .detail(movie):
            let vc = MovieDetailsHostingController(movie: movie)
            navigation?.pushViewController(vc, animated: true)
        }
    }
}
