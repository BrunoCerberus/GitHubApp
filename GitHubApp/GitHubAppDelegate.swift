//
//  GitHubAppDelegate.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import UIKit

/**
 * Main application delegate responsible for handling application lifecycle events.
 *
 * This delegate manages the app's initialization and scene configuration.
 * It's the entry point for the application and handles core setup tasks.
 */
@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    /**
     * Called when the application has finished launching.
     *
     * This is the first method called after the app is launched.
     * Use this method to perform any final initialization of your application.
     *
     * - Parameter application: The singleton app object
     * - Parameter launchOptions: A dictionary indicating the reason the app was launched
     * - Returns: `true` if the app launch was successful, `false` otherwise
     */
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Perform any additional setup here if needed
        // For now, we return true to indicate successful launch
        true
    }

    /**
     * Called when a new scene session is being created.
     *
     * This method is called when the system is creating a new scene session.
     * Use this method to select a configuration to create the new scene with.
     *
     * - Parameter application: The singleton app object
     * - Parameter connectingSceneSession: The scene session being created
     * - Parameter options: Additional options for the scene connection
     * - Returns: A configuration object for the new scene
     */
    func application(
        _: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Return the default scene configuration
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
