//
//  HomeViewTests.swift
//  GitHubAppTests
//
//  Created by bruno on 17/08/23.
//

import Combine
import SnapshotTesting
import SwiftUI
import XCTest

@testable import GitHubApp

/**
 * Snapshot tests for HomeView to ensure visual regressions are detected.
 */
@MainActor
final class HomeViewTests: XCTestCase {
    var router: HomeNavigationRouter!
    var mockService: MockHomeService!
    var viewModel: HomeViewModel!
    var view: HomeView<HomeNavigationRouter>!

    override func setUp() {
        super.setUp()

        router = HomeNavigationRouter()
        mockService = MockHomeService()
        viewModel = HomeViewModel(service: mockService)
        view = HomeView(router: router, viewModel: viewModel)
    }

    /// Snapshot of populated HomeView matches stored reference
    func testHomeView() async {
        let controller: UIViewController = view.wrappedViewController

        await viewModel.fetchData()

        // Using iPhone SE configuration but with iPhone 16 Pro dimensions
        let iPhone16ProConfig = ViewImageConfig(
            safeArea: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
            size: CGSize(width: 393, height: 852),
            traits: UITraitCollection()
        )

        assertSnapshot(matching: controller, as: .wait(for: 0.3, on: .image(on: iPhone16ProConfig)))
    }
}
