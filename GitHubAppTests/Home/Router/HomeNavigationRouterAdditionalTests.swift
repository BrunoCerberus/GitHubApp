//
//  HomeNavigationRouterAdditionalTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import Testing

@MainActor
struct HomeNavigationRouterAdditionalTests {
    @Test("Route uses coordinator when available")
    func routeUsesCoordinatorWhenAvailable() {
        let serviceLocator = ServiceLocator()
        // Avoid real network dependency in HomeView when coordinator builds
        try? APIKeysProvider.setMovieAPIKey("router-key")
        let coordinator = Coordinator(serviceLocator: serviceLocator)
        let router = HomeNavigationRouter(coordinator: coordinator)
        let movie = Movie(id: 3, title: "T", overview: "O", posterPath: nil)

        router.route(navigationEvent: .detail(movie))
        // Ensure the path appended a detail page
        #expect(!coordinator.path.isEmpty)
    }
}
