//
//  MovieDetailsViewTests.swift
//  GitHubAppTests
//
//  Created by bruno on 22/08/23.
//

import Combine
import SnapshotTesting
import SwiftUI
import XCTest

@testable import GitHubApp

/**
 * Snapshot tests for MovieDetailsView covering credits and reviews sections.
 */
final class MovieDetailsViewTests: XCTestCase {
    let movie: Movie = .init(id: 346_698,
                             title: "Barbie",
                             overview: "Barbie and Ken are having the time of their lives in the colorful " +
                                 "and seemingly perfect world of Barbie Land. However, when they get a chance to " +
                                 "go to the real world, they soon discover the joys and perils of living among humans.",
                             posterPath: "")
    var mockService: MockHomeService!
    var viewModel: MovieDetailsViewModel!
    var view: MovieDetailsView!

    override func setUp() {
        super.setUp()

        mockService = MockHomeService()
        viewModel = MovieDetailsViewModel(movie: movie, service: mockService)
        view = MovieDetailsView(viewModel: viewModel)
    }

    /// Snapshot of details view matches stored reference
    func testMovieDetailsView() {
        let controller: UIViewController = view.wrappedViewController

        viewModel.fetchData()

        // Using iPhone 16 Pro dimensions
        let iPhone16ProConfig = ViewImageConfig(
            safeArea: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
            size: CGSize(width: 393, height: 852),
            traits: UITraitCollection()
        )

        assertSnapshot(matching: controller, as: .wait(for: 0.3, on: .image(on: iPhone16ProConfig)))
    }
}
