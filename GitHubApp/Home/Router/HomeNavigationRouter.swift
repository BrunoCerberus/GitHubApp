//
//  HomeNavigationRouter.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

protocol HomeNavigationRouterDelegate: AnyObject {
    func showDetailScreen()
}

final class HomeNavigationRouter: NavigationRouter {
    weak var delegate: HomeNavigationRouterDelegate?

    func route(navigationEvent: HomeNavigationEvent) {
        switch navigationEvent {
        case .detail:
            delegate?.showDetailScreen()
        }
    }
}
