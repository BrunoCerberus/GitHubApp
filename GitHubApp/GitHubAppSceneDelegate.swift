//
//  GitHubAppSceneDelegate.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

// source: https://www.lopau.com/how-to-add-scenedelegate-to-an-existing-storyboard-project-in-xcode/

import SwiftUI
import UIKit

/**
 * Scene delegate responsible for managing the app's window and scene lifecycle.
 *
 * This delegate handles the creation and configuration of the app's main window
 * and sets up the root view controller with SwiftUI integration.
 * It also initializes the ServiceLocator with appropriate services based on
 * the current environment (debug/release, test/production).
 *
 * Note: This implementation prevents scene delegate execution during unit tests
 * to avoid conflicts with test environments.
 */
final class GitHubAppSceneDelegate: UIResponder, UIWindowSceneDelegate {
    /// The main window of the application
    var window: UIWindow?

    /**
     * Called when a scene is being created and connected to the app.
     *
     * This method sets up the main window and configures the root view controller
     * with the app's main coordinator view. It also applies the dark interface style
     * and initializes the ServiceLocator with appropriate services.
     *
     * - Parameter scene: The scene being connected
     * - Parameter willConnectTo: The session that the scene will connect to
     * - Parameter options: Additional options for the scene connection
     */
    func scene(_ scene: UIScene,
               willConnectTo _: UISceneSession,
               options _: UIScene.ConnectionOptions)
    {
        // Prevent scene delegate execution during unit tests to avoid conflicts
        guard ProcessInfo.processInfo.environment["IS_RUNNING_UNIT_TESTS"] != "YES" else { return }

        // Initialize services in ServiceLocator
        setupServices()

        // Ensure we have a valid window scene
        guard let windowScene: UIWindowScene = scene as? UIWindowScene else { return }

        // Create the root view controller with SwiftUI integration
        let rootView: UIHostingController<CoordinatorView> = UIHostingController(rootView: CoordinatorView())

        // Force dark mode for consistent UI appearance
        rootView.overrideUserInterfaceStyle = .dark

        // Create and configure the main window
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = rootView
        self.window = window

        // Make the window visible and set it as the key window
        window.makeKeyAndVisible()
    }

    /**
     * Setup services in the ServiceLocator based on current environment.
     *
     * This method registers the appropriate services (real or mock) based on
     * the current build configuration and test environment detection.
     */
    private func setupServices() {
        let serviceLocator = ServiceLocator.shared

        // Register HomeService based on environment
        #if DEBUG
            // Check if running in test environment
            if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
                // Use mock service for tests
                serviceLocator.register(HomeServiceProtocol.self, instance: MockService())
            } else {
                // Use real service for debug builds
                serviceLocator.register(HomeServiceProtocol.self, instance: HomeService())
            }
        #else
            // Use real service for release builds
            serviceLocator.register(HomeServiceProtocol.self, instance: HomeService())
        #endif
    }
}
