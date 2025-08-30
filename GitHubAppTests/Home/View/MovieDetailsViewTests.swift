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
        let view = MovieDetailsView(viewModel: viewModel)
        return (mockService, viewModel, view)
    }

    @Test("Movie details view snapshot matches stored reference")
    func movieDetailsView() async throws {
        // Ensure we're on the main thread for UIKit operations
        await MainActor.run {
            let (_, viewModel, view) = createTestComponents()
            let controller: UIViewController = view.wrappedViewController

            viewModel.fetchData()

            // Using iPhone 16 Pro dimensions
            let iPhone16ProConfig = ViewImageConfig(
                safeArea: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
                size: CGSize(width: 393, height: 852),
                traits: UITraitCollection()
            )

            assertSnapshot(of: controller, as: .wait(for: 0.8, on: .image(on: iPhone16ProConfig)))
        }
    }
}
