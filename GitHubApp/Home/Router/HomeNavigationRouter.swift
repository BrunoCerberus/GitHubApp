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

    @discardableResult
    func route(navigationEvent: HomeNavigationEvent) -> Bool {
        switch navigationEvent {
        case .detail:
            delegate?.showDetailScreen()
            return true
        }
    }
}
