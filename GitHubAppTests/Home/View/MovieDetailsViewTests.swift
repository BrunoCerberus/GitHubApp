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

final class MovieDetailsViewTests: XCTestCase {
    let movie = Movie(id: 346698,
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

    func testView() {
        let viewController = view.wrappedViewController
        let nav = UINavigationController(rootViewController: viewController)

        viewModel.fetchData()

        assertSnapshot(matching: nav, as: .wait(for: 0.3, on: .image(on: .iPhoneSe)))
    }
}
