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
 * Hosts a `TabView` with the main navigation stack and the Liked tab.
 */
struct CoordinatorView: View {
    @StateObject private var coordinator: Coordinator

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

            LikedMoviesView(viewModel: coordinator.likedMoviesViewModel)
                .tabItem {
                    Label("Liked", systemImage: "heart")
                }
        }
    }
}
