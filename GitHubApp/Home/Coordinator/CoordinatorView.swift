//
//  CoordinatorView.swift
//  GitHubApp
//
//  Created by bruno on 15/08/23.
//

import SwiftUI

struct CoordinatorView: View {
    @StateObject private var coordinator: Coordinator

    init() {
        // Create a ServiceLocator instance for this coordinator
        let serviceLocator = ServiceLocator()
        _coordinator = StateObject(wrappedValue: Coordinator(serviceLocator: serviceLocator))
    }

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
