//
//  NavigationRouter.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

public protocol NavigationRouter {
    // Navigation event that will be triggered by View
    associatedtype NavigationEventType

    func route(navigationEvent: NavigationEventType)
}
