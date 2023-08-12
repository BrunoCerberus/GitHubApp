//
//  HomeHostingViewController.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import SwiftUI

final class HomeHostingViewController<R: HomeNavigationRouter>: UIHostingController<HomeView<R>> {
    
    let router: R
    
    init(navigationRouter: R) {
        self.router = navigationRouter
        let rootView = HomeView<R>(router: navigationRouter, viewModel: HomeViewModel())
        super.init(rootView: rootView)
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Upcoming Movies"
        navigationController?.navigationBar.prefersLargeTitles = true
        self.router.navigation = navigationController
    }
}
