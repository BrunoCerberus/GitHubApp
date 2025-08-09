//
//  HomeHostingController.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import EntropyCore
import SwiftUI

/**
 * UIKit hosting controller for the Home SwiftUI view.
 *
 * Bridges SwiftUI navigation with UIKit when a `UINavigationController` is used.
 */
final class HomeHostingController<R: HomeNavigationRouter>: BaseHostingController<HomeView<R>> {
    /// Router used to trigger navigation actions
    let router: R

    /// Create a hosting controller for HomeView with a router
    init(navigationRouter: R) {
        router = navigationRouter
        let rootView = HomeView<R>(router: navigationRouter, viewModel: HomeViewModel())
        super.init(rootView: rootView)
    }

    @MainActor @objc dynamic required init?(coder _: NSCoder) {
        nil
    }

    /// Configure title, large titles and attach the navigation controller to the router
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Upcoming Movies"
        navigationController?.navigationBar.prefersLargeTitles = true
        router.navigation = navigationController
    }
}
