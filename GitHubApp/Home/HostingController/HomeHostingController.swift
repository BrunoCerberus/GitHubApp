//
//  HomeHostingController.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import EntropyCore
import SwiftUI

final class HomeHostingController<R: HomeNavigationRouter>: BaseHostingController<HomeView<R>> {
    let router: R

    init(navigationRouter: R) {
        router = navigationRouter
        let rootView = HomeView<R>(router: navigationRouter, viewModel: HomeViewModel())
        super.init(rootView: rootView)
    }

    @MainActor @objc dynamic required init?(coder _: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Upcoming Movies"
        navigationController?.navigationBar.prefersLargeTitles = true
        router.navigation = navigationController
    }
}
