//
//  NavigationRouter.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import UIKit

public protocol NavigationRouter {
    // Navigation event that will be triggered by View
    associatedtype NavigationEventType

    var navigation: UINavigationController? { get set }
    func route(navigationEvent: NavigationEventType)
}
