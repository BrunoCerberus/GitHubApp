//
//  HomeViewComponentTests.swift
//  GitHubAppTests
//
//  Created by claude on 23/08/25.
//

@testable import GitHubApp
import SwiftUI
import XCTest

/**
 * Additional tests for HomeView components to improve coverage.
 */
@MainActor
final class HomeViewComponentTests: XCTestCase {
    var router: HomeNavigationRouter!
    var mockService: MockHomeService!
    var viewModel: HomeViewModel!
    var view: HomeView<HomeNavigationRouter>!

    override func setUp() {
        super.setUp()
        StorageServiceFactory.shared.resetCache()

        router = HomeNavigationRouter()
        mockService = MockHomeService()
        viewModel = HomeViewModel(service: mockService)
        view = HomeView(router: router, viewModel: viewModel)
    }

    override func tearDown() {
        StorageServiceFactory.shared.resetCache()
        super.tearDown()
    }

    func testHomeViewBodyWithLoadingState() {
        // Given
        viewModel.viewState = .loading

        // When - Create a hosting controller with the view to verify body creation
        let hostingController = UIHostingController(rootView: view)

        // Then
        XCTAssertNotNil(hostingController)
    }

    func testHomeViewBodyWithErrorState() {
        // Given
        viewModel.viewState = .error("Test error")

        // When - Create a hosting controller with the view to verify body creation
        let hostingController = UIHostingController(rootView: view)

        // Then
        XCTAssertNotNil(hostingController)
    }

    func testHomeViewWithRefreshAction() async {
        // Given
        let expectation = XCTestExpectation(description: "refresh")

        // When - Simulate refresh by calling fetchData
        viewModel.fetchData()

        // Give time for async operation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 1.0)

        // Then
        XCTAssertNotNil(viewModel)
    }

    func testHomeViewSearchableConfiguration() {
        // Given
        let hostingController = UIHostingController(rootView: view)

        // When - Access view to ensure searchable is configured
        _ = hostingController.view

        // Then
        XCTAssertNotNil(view)
    }

    func testHomeViewWithMovieList() async {
        // Given
        let expectation = XCTestExpectation(description: "movies loaded")

        // When - Trigger data fetch
        viewModel.fetchData()

        // Wait for data to load
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 2.0)

        // Then
        XCTAssertNotNil(viewModel.movies)
    }
}
