//
//  GitHubAppSceneDelegate.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

// source: https://www.lopau.com/how-to-add-scenedelegate-to-an-existing-storyboard-project-in-xcode/

import UIKit
import SwiftUI

final class GitHubAppSceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_
               scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions
    ) {
        
        // This prevents the scene delegate being called when unit tests are running
        guard ProcessInfo.processInfo.environment["IS_RUNNING_UNIT_TESTS"] != "YES" else { return }
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let rootView = UINavigationController(rootViewController: HomeHostingController(navigationRouter: HomeNavigationRouter()))
//        let rootView = UIHostingController(rootView: CoordinatorView())
        rootView.overrideUserInterfaceStyle = .dark
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = rootView
        self.window = window
        window.makeKeyAndVisible()
    }
}
