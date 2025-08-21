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

    /// Service locator for dependency injection
    private let serviceLocator: ServiceLocator = .init()

    /// Deeplink manager for handling URL schemes
    private let deeplinkManager = DeeplinkManager()

    /// Deeplink router for handling navigation
    private var deeplinkRouter: DeeplinkRouter?

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

        // Create the root view controller with SwiftUI integration and pass the configured ServiceLocator
        let rootView: UIHostingController<CoordinatorView> = UIHostingController(
            rootView: CoordinatorView(serviceLocator: serviceLocator)
        )

        // Force dark mode for consistent UI appearance
        rootView.overrideUserInterfaceStyle = .dark

        // Create and configure the main window
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = rootView
        self.window = window

        // Initialize deeplink router with the coordinator
        setupDeeplinkRouter(with: rootView)

        // Setup notification observer for coordinator availability
        setupCoordinatorObserver()

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
        #if DEBUG
            // Check if running in test environment
            if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
                // Use mock services for tests
                serviceLocator.register(HomeServiceProtocol.self, instance: MockService())
                serviceLocator.register(LikedServiceProtocol.self, instance: MockLikedService())
            } else {
                // Use real services for debug builds
                serviceLocator.register(HomeServiceProtocol.self, instance: HomeService())
                serviceLocator.register(LikedServiceProtocol.self, instance: LikedService())
            }
        #else
            // Use real services for release builds
            serviceLocator.register(HomeServiceProtocol.self, instance: HomeService())
            serviceLocator.register(LikedServiceProtocol.self, instance: LikedService())
        #endif
    }

    /**
     * Setup deeplink router with the coordinator from the root view.
     *
     * This method extracts the coordinator from the SwiftUI view hierarchy
     * and configures the deeplink router for navigation.
     *
     * - Parameter rootView: The root hosting controller containing the coordinator
     */
    private func setupDeeplinkRouter(with rootView: UIHostingController<CoordinatorView>) {
        // We need to wait for the coordinator to be available
        // This will be called after the view appears
        DispatchQueue.main.async { [weak self] in
            self?.setupDeeplinkRouterAfterViewAppears(rootView: rootView)
        }
    }

    /**
     * Setup deeplink router after the view has appeared and coordinator is available.
     *
     * - Parameter rootView: The root hosting controller
     */
    private func setupDeeplinkRouterAfterViewAppears(rootView: UIHostingController<CoordinatorView>) {
        // Extract the coordinator from the view hierarchy
        if let coordinatorView = rootView.rootView as? CoordinatorView {
            // The coordinator will be available after the view appears
            // We'll set it up in the coordinator view
        }
    }

    /**
     * Setup notification observer for coordinator availability.
     */
    private func setupCoordinatorObserver() {
        NotificationCenter.default.addObserver(
            forName: .coordinatorDidBecomeAvailable,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let coordinator = notification.object as? Coordinator {
                self?.deeplinkRouter = DeeplinkRouter(
                    deeplinkManager: self?.deeplinkManager ?? DeeplinkManager(),
                    coordinator: coordinator
                )
            }
        }
    }

    /**
     * Handle URL opening for the scene.
     *
     * This method is called when the app is opened via a custom URL scheme
     * while the app is running in the foreground.
     *
     * - Parameter scene: The scene that received the URL
     * - Parameter urlContexts: The URL contexts that were opened
     */
    func scene(_: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for urlContext in URLContexts {
            let url = urlContext.url
            if deeplinkManager.isValidDeeplink(url: url) {
                // Process the deeplink if the router is available
                _ = deeplinkRouter?.process(url: url)
            }
        }
    }

    /**
     * Handle universal links when the app is being activated.
     *
     * This method is called when the app is opened via a universal link.
     * Universal links use HTTPS URLs and are handled differently from custom schemes.
     *
     * - Parameter scene: The scene that received the activity
     * - Parameter userActivity: The user activity containing the universal link
     */
    func scene(_: UIScene, continue userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL
        else {
            return
        }

        if deeplinkManager.isValidDeeplink(url: url) {
            // Process the universal link if the router is available
            _ = deeplinkRouter?.process(url: url)
        }
    }
}
