//
//  CoordinatorView.swift
//  GitHubApp
//
//  Created by bruno on 15/08/23.
//

import SwiftUI

/**
 * Root SwiftUI container that wires the Coordinator into the UI.
 *
 * Hosts a `TabView` with the main navigation stack and the Favorites tab.
 */
struct CoordinatorView: View {
    @StateObject private var coordinator: Coordinator

    /// Reference to the scene delegate for deeplink setup
    @Environment(\.scenePhase) private var scenePhase

    /**
     * Create the view with an injected ServiceLocator.
     *
     * - Parameter serviceLocator: Shared dependency resolver for the app
     */
    init(serviceLocator: ServiceLocator) {
        // Use the provided ServiceLocator instance instead of creating a new one
        _coordinator = StateObject(wrappedValue: Coordinator(serviceLocator: serviceLocator))
    }

    /// View content composed of a tab bar and navigation stack
    var body: some View {
        TabView {
            NavigationStack(path: $coordinator.path) {
                coordinator.build(page: .home)
                    .navigationDestination(for: Page.self) { page in
                        coordinator.build(page: page)
                    }
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .environmentObject(coordinator)

            FavoritesMoviesView(viewModel: coordinator.favoriteMoviesViewModel)
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }

            SettingsView(viewModel: coordinator.settingsViewModel)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }

        .onAppear {
            setupDeeplinkRouter()
        }
    }

    /**
     * Setup deeplink router with the coordinator.
     *
     * This method configures the deeplink router to use this coordinator
     * for navigation when deeplinks are processed.
     */
    private func setupDeeplinkRouter() {
        // Get the scene delegate to setup the deeplink router
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           windowScene.delegate as? GitHubAppSceneDelegate != nil
        {
            // Set the deeplink router in the scene delegate
            // We need to use a different approach since we can't directly access the scene delegate
            // For now, we'll use a notification-based approach
            NotificationCenter.default.post(
                name: .coordinatorDidBecomeAvailable,
                object: coordinator
            )
        }
    }
}
