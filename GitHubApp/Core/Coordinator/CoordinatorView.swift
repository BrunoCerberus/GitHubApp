//
//  CoordinatorView.swift
//  GitHubApp
//
//  Created by bruno on 15/08/23.
//

import SwiftUI

struct CoordinatorView: View {

    @StateObject private var coordinator = Coordinator()

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.build(page: .home)
                .navigationDestination(for: Page.self) { page in
                    coordinator.build(page: page)
                }
        }
        .environmentObject(coordinator)
    }
}
