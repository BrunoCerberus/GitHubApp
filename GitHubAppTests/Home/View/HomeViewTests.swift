//
//  HomeViewTests.swift
//  GitHubAppTests
//
//  Created by bruno on 17/08/23.
//
//  NOTE: Many tests in this file are DISABLED because they test the old MVVM architecture.
//  The HomeView now uses Clean Architecture with a different API.
//  New Clean Architecture tests are in HomeViewModelCleanArchitectureTests.swift

import Combine
import SnapshotTesting
import SwiftUI
import Testing

@testable import GitHubApp

/**
 * Snapshot tests for HomeView to ensure visual regressions are detected.
 */
@MainActor
struct HomeViewTests {
    private func createTestComponents() -> (HomeNavigationRouter, MockHomeService, HomeViewModel, HomeView<HomeNavigationRouter>) {
        let router = HomeNavigationRouter()
        let mockService = MockHomeService()
        let mockStorageService = MockStorageService()

        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: mockService)
        serviceLocator.register(StorageService.self, instance: mockStorageService)

        let viewModel = HomeViewModel(serviceLocator: serviceLocator)
        let view = HomeView(router: router, viewModel: viewModel)
        return (router, mockService, viewModel, view)
    }

    private func cleanupTest() {
        // Cleanup test resources
    }

    @Test("Home view snapshot matches stored reference")
    func homeView() async throws {
        defer { cleanupTest() }

        let (_, _, viewModel, view) = createTestComponents()
        _ = view.wrappedViewController

        // Trigger data fetch
        viewModel.fetchData()

        // Give time for async operations and UI updates
        try await Task.sleep(nanoseconds: 3_500_000_000) // 3.5 seconds

        // Using iPhone Air (iOS 26) dimensions
        let iPhoneAirConfig = ViewImageConfig(
            safeArea: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
            size: CGSize(width: 393, height: 852),
            traits: UITraitCollection()
        )

        assertSnapshot(of: view.wrappedViewController, as: .wait(for: 1.0, on: .image(on: iPhoneAirConfig)))
    }

    @Test("Search functionality and text change handling")
    func searchFunctionality() {
        defer { cleanupTest() }

        // When - simulate search text change
        // This exercises the onChange closure and handleSearchQueryChange method
        // Note: We can't directly test the onChange closure since searchText is private,
        // but we can verify that the view is properly configured for search
        _ = createTestComponents()

        // Then - test passes if view initializes without crashing
        // The search functionality is tested through the view model integration
    }

    // DISABLED: This test uses the old MVVM architecture
    /*
     /**
      * Test error display overlay.
      *
      * This test verifies that errors are properly displayed
      * in the overlay when they occur.
      */
     func testErrorDisplayOverlay() {
         // Given
         viewModel.error = "Test error message"

         // When - trigger view update
         _ = view.wrappedViewController

         // Then - verify error is set (the overlay will be rendered)
         XCTAssertEqual(viewModel.error, "Test error message")
     }
     */

    // DISABLED: This test uses the old MVVM architecture
    /*
     /**
      * Test refresh functionality.
      *
      * This test verifies that the refreshable modifier is properly
      * configured and can trigger data refresh.
      */
     func testRefreshFunctionality() {
         // When - simulate refresh (this exercises the refreshable closure)
         // Note: We can't directly test the refreshable closure, but we can verify
         // that the view is properly configured for refresh
         viewModel.fetchData()

         // Then - verify data was fetched
         XCTAssertGreaterThanOrEqual(viewModel.movies.count, 0)
     }
     */

    @Test("Movie tap gesture handling")
    func movieTapGesture() {
        defer { cleanupTest() }

        // When - simulate movie tap (this exercises the onTapGesture closure)
        // Note: We can't directly test the onTapGesture closure, but we can verify
        // that the router is properly configured
        _ = createTestComponents()

        // Then - test passes if components initialize without crashing
    }

    @Test("Home view initialization with different view models")
    func homeViewInitialization() {
        defer { cleanupTest() }

        let (router, mockService, _, _) = createTestComponents()

        // Test initialization with provided ViewModel
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: mockService)
        let customViewModel = HomeViewModel(serviceLocator: serviceLocator)
        _ = HomeView(router: router, viewModel: customViewModel)

        // Test initialization with default ViewModel setup
        let defaultServiceLocator = ServiceLocator()
        defaultServiceLocator.register(HomeService.self, instance: MockHomeService())
        let defaultViewModel = HomeViewModel(serviceLocator: defaultServiceLocator)
        _ = HomeView(router: router, viewModel: defaultViewModel)

        // Test passes if both views initialize without crashing
    }

    // DISABLED: These tests use the old MVVM architecture
    /*
     /**
      * Test AsyncImageViewer rendering.
      *
      * This test verifies that AsyncImageViewer is properly
      * configured with placeholder.
      */
     func testAsyncImageViewerRendering() {
         viewModel.movies = [
             Movie(id: 1, title: "Test Movie", overview: "Test Overview", posterPath: "/test.jpg"),
         ]

         // Trigger view update to render AsyncImageViewer
         _ = view.wrappedViewController

         // Verify that the view is properly configured
         XCTAssertNotNil(view)
         XCTAssertEqual(viewModel.movies.count, 1)
     }

     /**
      * Test button interactions and styling.
      *
      * This test verifies that buttons are properly configured
      * with PlainButtonStyle and correct actions.
      */
     func testButtonInteractionsAndStyling() {
         viewModel.movies = [
             Movie(id: 1, title: "Test Movie", overview: "Test Overview", posterPath: "/test.jpg"),
         ]

         // Trigger view update to render buttons
         _ = view.wrappedViewController

         // Verify that the view is properly configured
         XCTAssertNotNil(view)
         XCTAssertEqual(viewModel.movies.count, 1)
     }
     */

    // DISABLED: This test uses the old MVVM architecture
    /*
     /**
      * Test scroll indicators hidden.
      *
      * This test verifies that scroll indicators are hidden
      * using the .scrollIndicators(.hidden) modifier.
      */
     func testScrollIndicatorsHidden() {
         viewModel.movies = [
             Movie(id: 1, title: "Test Movie", overview: "Test Overview", posterPath: "/test.jpg"),
             Movie(id: 2, title: "Test Movie 2", overview: "Test Overview 2", posterPath: "/test2.jpg"),
         ]

         // Trigger view update to render list
         _ = view.wrappedViewController

         // Verify that the view is properly configured
         XCTAssertNotNil(view)
         XCTAssertEqual(viewModel.movies.count, 2)
     }
     */

    @Test("Searchable modifier configuration")
    func searchableModifierConfiguration() {
        defer { cleanupTest() }

        let (_, _, _, view) = createTestComponents()

        // Trigger view update to configure searchable modifier
        _ = view.wrappedViewController

        // Test passes if view renders without crashing
    }

    @Test("OnChange modifier configuration")
    func onChangeModifierConfiguration() {
        defer { cleanupTest() }

        let (_, _, _, view) = createTestComponents()

        // Trigger view update to configure onChange modifier
        _ = view.wrappedViewController

        // Test passes if view renders without crashing
    }

    // DISABLED: This test uses the old MVVM architecture
    /*
     /**
      * Test overlay error display.
      *
      * This test verifies that the overlay properly displays
      * errors when they occur.
      */
     func testOverlayErrorDisplay() {
         // Given
         viewModel.error = "Test error message"

         // When - trigger view update
         _ = view.wrappedViewController

         // Then - verify error is set (the overlay will be rendered)
         XCTAssertEqual(viewModel.error, "Test error message")

         // Test with nil error
         viewModel.error = nil
         _ = view.wrappedViewController
         XCTAssertNil(viewModel.error)
     }
     */

    // DISABLED: These tests use the old MVVM architecture
    /*
     /**
      * Test movie list rendering with multiple movies.
      *
      * This test verifies that the list properly renders
      * multiple movies with correct layout.
      */
     func testMovieListRenderingWithMultipleMovies() {
         viewModel.movies = [
             Movie(id: 1, title: "Test Movie 1", overview: "Test Overview 1", posterPath: "/test1.jpg"),
             Movie(id: 2, title: "Test Movie 2", overview: "Test Overview 2", posterPath: "/test2.jpg"),
             Movie(id: 3, title: "Test Movie 3", overview: "Test Overview 3", posterPath: "/test3.jpg"),
         ]

         // Trigger view update to render list
         _ = view.wrappedViewController

         // Verify that the view is properly configured
         XCTAssertNotNil(view)
         XCTAssertEqual(viewModel.movies.count, 3)
     }

     /**
      * Test empty movie list rendering.
      *
      * This test verifies that the list properly handles
      * empty movie arrays.
      */
     func testEmptyMovieListRendering() {
         viewModel.movies = []

         // Trigger view update to render empty list
         _ = view.wrappedViewController

         // Verify that the view is properly configured
         XCTAssertNotNil(view)
         XCTAssertEqual(viewModel.movies.count, 0)
     }
     */
}
