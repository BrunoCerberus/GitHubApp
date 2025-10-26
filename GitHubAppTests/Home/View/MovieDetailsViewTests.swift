//
//  MovieDetailsViewTests.swift
//  GitHubAppTests
//
//  Created by bruno on 22/08/23.
//

import Combine
import SnapshotTesting
import SwiftUI
import Testing

@testable import GitHubApp

/**
 * Snapshot tests for MovieDetailsView covering credits and reviews sections.
 */
@MainActor
struct MovieDetailsViewTests {
    let movie: Movie = .init(id: 346_698,
                             title: "Barbie",
                             overview: "Barbie and Ken are having the time of their lives in the colorful " +
                                 "and seemingly perfect world of Barbie Land. However, when they get a chance to " +
                                 "go to the real world, they soon discover the joys and perils of living among humans.",
                             posterPath: "")

    private func createTestComponents() -> (MockHomeService, MovieDetailsViewModel, MovieDetailsView) {
        // Ensure API key is available for any fallback scenarios
        try? APIKeysProvider.setMovieAPIKey("test-api-key-for-movie-details")

        let mockService = MockHomeService()
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: mockService)
        let viewModel = MovieDetailsViewModel(movie: movie, serviceLocator: serviceLocator)
        let router = MovieDetailsNavigationRouter()
        let view = MovieDetailsView(router: router, viewModel: viewModel)
        return (mockService, viewModel, view)
    }

    @Test("Movie details view snapshot matches stored reference")
    func movieDetailsView() async throws {
        let (_, viewModel, view) = createTestComponents()
        let controller: UIViewController = view.wrappedViewController

        // Trigger data fetch
        viewModel.fetchData()

        // Give time for async operations and UI updates (credits and reviews to load)
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        // Using iPhone Air (iOS 26) dimensions
        let iPhoneAirConfig = ViewImageConfig(
            safeArea: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
            size: CGSize(width: 393, height: 852),
            traits: UITraitCollection()
        )

        await MainActor.run {
            assertSnapshot(of: controller, as: .wait(for: 0.5, on: .image(on: iPhoneAirConfig)))
        }
    }
}
