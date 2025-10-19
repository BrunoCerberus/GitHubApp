//
//  SearchViewTests.swift
//  GitHubAppTests
//
//  Snapshot tests for SearchView to ensure visual regressions are detected.

import Combine
import SnapshotTesting
import SwiftUI
import Testing

@testable import GitHubApp

/**
 * Snapshot tests for SearchView to ensure visual regressions are detected.
 */
@MainActor
struct SearchViewTests {
    private func createTestComponents(mockService: HomeService? = nil) -> (SearchNavigationRouter, SearchViewModel, SearchView) {
        let router = SearchNavigationRouter()
        let service = mockService ?? MockHomeService()
        let mockStorageService = MockStorageService()

        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: service)
        serviceLocator.register(StorageService.self, instance: mockStorageService)

        // Configure API key for testing
        try? APIKeysProvider.setMovieAPIKey("unit-test-key")

        let viewModel = SearchViewModel(serviceLocator: serviceLocator)
        let view = SearchView(router: router, viewModel: viewModel, serviceLocator: serviceLocator)
        return (router, viewModel, view)
    }

    private func cleanupTest() {
        try? APIKeysProvider.removeMovieAPIKey()
    }

    private func iPhoneAirConfig() -> ViewImageConfig {
        ViewImageConfig(
            safeArea: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
            size: CGSize(width: 393, height: 852),
            traits: UITraitCollection()
        )
    }

    @Test("Search view initial state snapshot matches stored reference")
    func searchViewInitialState() async throws {
        defer { cleanupTest() }

        let (_, _, view) = createTestComponents()
        let viewController = view.wrappedViewController

        // Give time for initial UI to render
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        assertSnapshot(of: viewController, as: .wait(for: 0.5, on: .image(on: iPhoneAirConfig())))
    }

    @Test("Search functionality and text change handling")
    func searchFunctionality() {
        defer { cleanupTest() }

        // When - simulate search functionality
        // This exercises the onChange closure and handleSearchQueryChange method
        // Note: We can't directly test the onChange closure since searchText is private,
        // but we can verify that the view is properly configured for search
        _ = createTestComponents()

        // Then - test passes if view initializes without crashing
        // The search functionality is tested through the view model integration
    }

    @Test("Search view initialization")
    func searchViewInitialization() {
        defer { cleanupTest() }

        let (router, _, _) = createTestComponents()

        // Test initialization with provided ViewModel
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: MockHomeService())
        try? APIKeysProvider.setMovieAPIKey("unit-test-key")

        let customViewModel = SearchViewModel(serviceLocator: serviceLocator)
        _ = SearchView(router: router, viewModel: customViewModel, serviceLocator: serviceLocator)

        // Test initialization with default ViewModel setup
        let defaultServiceLocator = ServiceLocator()
        defaultServiceLocator.register(HomeService.self, instance: MockHomeService())
        let defaultViewModel = SearchViewModel(serviceLocator: defaultServiceLocator)
        _ = SearchView(router: router, viewModel: defaultViewModel, serviceLocator: defaultServiceLocator)

        // Test passes if both views initialize without crashing
    }

    @Test("Searchable modifier configuration")
    func searchableModifierConfiguration() {
        defer { cleanupTest() }

        let (_, _, view) = createTestComponents()

        // Trigger view update to configure searchable modifier
        _ = view.wrappedViewController

        // Test passes if view renders without crashing
    }

    @Test("OnChange modifier configuration")
    func onChangeModifierConfiguration() {
        defer { cleanupTest() }

        let (_, _, view) = createTestComponents()

        // Trigger view update to configure onChange modifier
        _ = view.wrappedViewController

        // Test passes if view renders without crashing
    }

    @Test("Navigation destination configuration")
    func navigationDestinationConfiguration() {
        defer { cleanupTest() }

        let (_, _, view) = createTestComponents()

        // Trigger view update to configure navigation destination
        _ = view.wrappedViewController

        // Test passes if view renders without crashing
    }

    @Test("Empty state view rendering")
    func emptyStateViewRendering() {
        defer { cleanupTest() }

        let (_, _, view) = createTestComponents()

        // Trigger view update to render empty state
        _ = view.wrappedViewController

        // Test passes if view renders without crashing
        // Empty state is the default initial view
    }

    @Test("No results view rendering")
    func noResultsViewRendering() async throws {
        defer { cleanupTest() }

        let (_, viewModel, view) = createTestComponents(mockService: MockHomeService())

        _ = view.wrappedViewController

        // Trigger search with query that returns no results
        viewModel.searchMovies(query: "nonexistentmovie123456")

        // Give time for search to complete
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        // Test passes if view renders no results state without crashing
    }

    @Test("Favorite toggle button interaction")
    func favoriteToggleButtonInteraction() {
        defer { cleanupTest() }

        let (_, _, view) = createTestComponents()

        // Trigger view update to render buttons
        _ = view.wrappedViewController

        // Test passes if view renders without crashing
        // Button interactions are tested through view model tests
    }

    @Test("Load more movies pagination")
    func loadMoreMoviesPagination() async throws {
        defer { cleanupTest() }

        let (_, viewModel, view) = createTestComponents()
        _ = view.wrappedViewController

        // Trigger initial search
        viewModel.searchMovies(query: "test")

        // Give time for search to complete
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        // Trigger load more
        viewModel.loadMoreMovies()

        // Give time for pagination to complete
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        // Test passes if pagination works without crashing
    }
}
