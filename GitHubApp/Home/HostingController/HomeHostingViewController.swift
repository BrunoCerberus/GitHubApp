//
//  HomeHostingViewController.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import SwiftUI

final class HomeHostingViewController<R: HomeNavigationRouter>: UIHostingController<HomeView<R>> {
    
    init(navigationRouter: R) {
        let rootView = HomeView<R>(router: navigationRouter)
        super.init(rootView: rootView)
        navigationRouter.delegate = self
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension HomeHostingViewController: HomeNavigationRouterDelegate {
    func showDetailScreen() {
        
    }
}
