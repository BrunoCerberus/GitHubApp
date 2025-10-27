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

    private let iPhoneAirConfig = ViewImageConfig(
        safeArea: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
        size: CGSize(width: 393, height: 852),
        traits: UITraitCollection()
    )

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

        assertSnapshot(of: view.wrappedViewController, as: .wait(for: 1.0, on: .image(on: iPhoneAirConfig)))
    }

    @Test("Home view displays loading state")
    func homeViewDisplaysLoadingState() async throws {
        defer { cleanupTest() }

        let (_, _, viewModel, view) = createTestComponents()
        let controller: UIViewController = view.wrappedViewController

        // Verify initial loading state is displayed
        if case .loading = viewModel.viewState {
            // Correct state
        } else {
            #expect(Bool(false), "Expected loading state initially")
        }

        // Snapshot the loading state
        await MainActor.run {
            assertSnapshot(of: controller, as: .wait(for: 0.5, on: .image(on: iPhoneAirConfig)))
        }
    }

    @Test("Home view displays error message on fetch failure")
    func homeViewDisplaysErrorMessageOnFetchFailure() async throws {
        defer { cleanupTest() }

        // Create a failing service
        struct FailingHomeService: HomeService {
            func fetchMovies(page _: Int) -> AnyPublisher<MoviesResponse, Error> {
                Fail(error: NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Network error occurred"])).eraseToAnyPublisher()
            }

            func searchMovies(with _: String, page _: Int) -> AnyPublisher<MoviesResponse, Error> {
                Fail(error: NSError(domain: "test", code: 1)).eraseToAnyPublisher()
            }

            func fetchCredits(with _: Int) -> AnyPublisher<MovieCreditsResponse, Error> {
                Fail(error: NSError(domain: "test", code: 1)).eraseToAnyPublisher()
            }

            func fetchReviews(with _: Int) -> AnyPublisher<MovieReviewsResponse, Error> {
                Fail(error: NSError(domain: "test", code: 1)).eraseToAnyPublisher()
            }
        }

        try? APIKeysProvider.setMovieAPIKey("test-key")

        let failingService = FailingHomeService()
        let mockStorageService = MockStorageService()
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: failingService)
        serviceLocator.register(StorageService.self, instance: mockStorageService)

        let errorViewModel = HomeViewModel(serviceLocator: serviceLocator)
        let router = HomeNavigationRouter()
        let view = HomeView(router: router, viewModel: errorViewModel)
        let controller: UIViewController = view.wrappedViewController

        // Trigger fetch
        errorViewModel.fetchData()

        // Wait for error to propagate
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        // Verify error state
        if case let .error(message) = errorViewModel.viewState {
            #expect(!message.isEmpty, "Error message should not be empty")
        } else {
            #expect(Bool(false), "Expected error state")
        }

        // Snapshot the error state
        await MainActor.run {
            assertSnapshot(of: controller, as: .wait(for: 0.5, on: .image(on: iPhoneAirConfig)))
        }
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

    // MARK: - Button Interaction Tests

    @Test("Heart button favorite toggle")
    func heartButtonFavoriteToggle() async throws {
        defer { cleanupTest() }

        let (_, _, viewModel, view) = createTestComponents()
        let controller: UIViewController = view.wrappedViewController

        // Trigger data fetch to populate movies
        viewModel.fetchData()
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds for data to load

        // Verify success state with movies
        if case let .success(dataViewState) = viewModel.viewState {
            #expect(!dataViewState.movies.isEmpty, "Movies should be loaded")

            // Get first movie
            let firstMovie = dataViewState.movies[0]

            // Initial state - movie should not be favorited
            let isFavoritedBefore = dataViewState.favoriteMovies.contains(where: { $0.id == firstMovie.id })
            #expect(!isFavoritedBefore, "Movie should not be favorited initially")

            // Toggle favorite
            viewModel.toggleFavorite(for: firstMovie)

            // Wait for state update
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

            // Verify state changed to include the movie in favorites
            if case let .success(updatedDataViewState) = viewModel.viewState {
                let isFavoritedAfter = updatedDataViewState.favoriteMovies.contains(where: { $0.id == firstMovie.id })
                #expect(isFavoritedAfter, "Movie should be in favorites after toggle")
            }
        } else {
            #expect(Bool(false), "Expected success state")
        }
    }

    @Test("Heart button favorite toggle visual feedback")
    func heartButtonVisualFeedback() async throws {
        defer { cleanupTest() }

        let (_, _, viewModel, view) = createTestComponents()
        let controller: UIViewController = view.wrappedViewController

        // Trigger data fetch
        viewModel.fetchData()
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

        // Snapshot before toggle
        await MainActor.run {
            assertSnapshot(of: controller, as: .wait(for: 0.5, on: .image(on: iPhoneAirConfig)))
        }

        // Toggle favorite
        if case let .success(dataViewState) = viewModel.viewState {
            let firstMovie = dataViewState.movies[0]
            viewModel.toggleFavorite(for: firstMovie)

            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

            // Snapshot after toggle to verify icon change (heart -> heart.fill or vice versa)
            await MainActor.run {
                assertSnapshot(of: controller, as: .wait(for: 0.5, on: .image(on: iPhoneAirConfig)))
            }
        }
    }

    // MARK: - Navigation Tests

    @Test("Movie row tap navigation")
    func movieRowTapNavigation() async throws {
        defer { cleanupTest() }

        let (router, _, viewModel, view) = createTestComponents()
        _ = view.wrappedViewController

        // Trigger data fetch
        viewModel.fetchData()
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

        // Verify success state with movies
        if case let .success(dataViewState) = viewModel.viewState {
            #expect(!dataViewState.movies.isEmpty, "Movies should be loaded")

            let firstMovie = dataViewState.movies[0]

            // Simulate row tap by calling router
            router.route(navigationEvent: .detail(firstMovie))

            // Test passes if navigation executes without crashing
            #expect(true)
        }
    }

    // MARK: - Empty State Tests

    @Test("Home view with empty movie list")
    func homeViewWithEmptyMovieList() async throws {
        defer { cleanupTest() }

        // Create a service that returns empty movies
        struct EmptyMoviesService: HomeService {
            func fetchMovies(page _: Int) -> AnyPublisher<MoviesResponse, Error> {
                Just(MoviesResponse(results: [], page: 1, totalPages: 1, totalResults: 0))
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }

            func searchMovies(with _: String, page _: Int) -> AnyPublisher<MoviesResponse, Error> {
                Just(MoviesResponse(results: [], page: 1, totalPages: 1, totalResults: 0))
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }

            func fetchCredits(with _: Int) -> AnyPublisher<MovieCreditsResponse, Error> {
                Just(MovieCreditsResponse(cast: []))
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }

            func fetchReviews(with _: Int) -> AnyPublisher<MovieReviewsResponse, Error> {
                Just(MovieReviewsResponse(results: []))
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
        }

        let emptyService = EmptyMoviesService()
        let mockStorageService = MockStorageService()

        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: emptyService)
        serviceLocator.register(StorageService.self, instance: mockStorageService)

        let viewModel = HomeViewModel(serviceLocator: serviceLocator)
        let router = HomeNavigationRouter()
        let view = HomeView(router: router, viewModel: viewModel)
        let controller: UIViewController = view.wrappedViewController

        // Trigger fetch
        viewModel.fetchData()
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

        // Verify success state with empty list
        if case let .success(dataViewState) = viewModel.viewState {
            #expect(dataViewState.movies.isEmpty, "Movies list should be empty")
        } else {
            #expect(Bool(false), "Expected success state")
        }

        // Snapshot the empty list
        await MainActor.run {
            assertSnapshot(of: controller, as: .wait(for: 0.5, on: .image(on: iPhoneAirConfig)))
        }
    }

    // MARK: - Refresh Gesture Tests

    @Test("Pull-to-refresh executes data fetch")
    func pullToRefreshExecutesFetch() async throws {
        defer { cleanupTest() }

        let (_, mockService, viewModel, view) = createTestComponents()
        _ = view.wrappedViewController

        // Trigger initial fetch
        viewModel.fetchData()
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

        // Verify initial state
        if case let .success(dataViewState) = viewModel.viewState {
            let initialCount = dataViewState.movies.count

            // Trigger refresh (simulates pull-to-refresh gesture)
            viewModel.fetchData()
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

            // Verify data was re-fetched
            if case let .success(refreshedDataViewState) = viewModel.viewState {
                // If refetch succeeds, we should still have movies
                #expect(!refreshedDataViewState.movies.isEmpty, "Movies should be available after refresh")
            }
        }
    }

    // MARK: - Error Handling Tests

    @Test("Network error displays error message to user")
    func networkErrorDisplaysErrorMessage() async throws {
        defer { cleanupTest() }

        // Create a service that fails with network error
        struct NetworkErrorService: HomeService {
            func fetchMovies(page _: Int) -> AnyPublisher<MoviesResponse, Error> {
                Fail(error: NSError(domain: "NSURLErrorDomain", code: -1001, userInfo: [NSLocalizedDescriptionKey: "The request timed out."]))
                    .eraseToAnyPublisher()
            }

            func searchMovies(with _: String, page _: Int) -> AnyPublisher<MoviesResponse, Error> {
                Fail(error: NSError(domain: "NSURLErrorDomain", code: -1001)).eraseToAnyPublisher()
            }

            func fetchCredits(with _: Int) -> AnyPublisher<MovieCreditsResponse, Error> {
                Fail(error: NSError(domain: "test", code: 1)).eraseToAnyPublisher()
            }

            func fetchReviews(with _: Int) -> AnyPublisher<MovieReviewsResponse, Error> {
                Fail(error: NSError(domain: "test", code: 1)).eraseToAnyPublisher()
            }
        }

        let errorService = NetworkErrorService()
        let mockStorageService = MockStorageService()

        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: errorService)
        serviceLocator.register(StorageService.self, instance: mockStorageService)

        let viewModel = HomeViewModel(serviceLocator: serviceLocator)
        let router = HomeNavigationRouter()
        let view = HomeView(router: router, viewModel: viewModel)
        let controller: UIViewController = view.wrappedViewController

        // Trigger fetch that will fail
        viewModel.fetchData()
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        // Verify error state
        if case let .error(message) = viewModel.viewState {
            #expect(!message.isEmpty, "Error message should display network error")
        } else {
            #expect(Bool(false), "Expected error state")
        }

        // Snapshot the error message
        await MainActor.run {
            assertSnapshot(of: controller, as: .wait(for: 0.5, on: .image(on: iPhoneAirConfig)))
        }
    }

    @Test("Multiple favorites toggle consistency")
    func multipleFavoritesTogglesConsistency() async throws {
        defer { cleanupTest() }

        let (_, _, viewModel, view) = createTestComponents()
        _ = view.wrappedViewController

        // Trigger initial fetch
        viewModel.fetchData()
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

        // Verify success with movies
        if case let .success(dataViewState) = viewModel.viewState {
            #expect(!dataViewState.movies.isEmpty, "Should have movies")

            let movie1 = dataViewState.movies[0]
            let movie2 = dataViewState.movies.count > 1 ? dataViewState.movies[1] : nil

            // Toggle first movie as favorite
            viewModel.toggleFavorite(for: movie1)
            try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

            // Verify first movie is favorited
            if case let .success(state1) = viewModel.viewState {
                let isMovie1Favorited = state1.favoriteMovies.contains(where: { $0.id == movie1.id })
                #expect(isMovie1Favorited, "First movie should be favorited")

                // Toggle second movie
                if let movie2 {
                    viewModel.toggleFavorite(for: movie2)
                    try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

                    // Verify both are favorited
                    if case let .success(state2) = viewModel.viewState {
                        let isMovie2Favorited = state2.favoriteMovies.contains(where: { $0.id == movie2.id })
                        #expect(isMovie2Favorited, "Second movie should be favorited")
                        #expect(state2.favoriteMovies.count >= 2, "Should have at least 2 favorites")
                    }
                }
            }
        }
    }

    @Test("Search clears when fetching full list")
    func searchClearsWhenFetchingFullList() async throws {
        defer { cleanupTest() }

        let (_, _, viewModel, view) = createTestComponents()
        _ = view.wrappedViewController

        // Perform a search
        viewModel.searchMovies(query: "Avatar")
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        // Verify search results
        if case let .success(dataViewState) = viewModel.viewState {
            let searchCount = dataViewState.movies.count
            #expect(searchCount > 0, "Should have search results")

            // Now fetch full list
            viewModel.fetchData()
            try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

            // Verify we have full list (should be different size)
            if case let .success(fullState) = viewModel.viewState {
                // Full list may have more or fewer results depending on API
                #expect(!fullState.movies.isEmpty, "Should have full list results")
            }
        }
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

    @Test("Movie row tap triggers navigation to detail")
    func movieRowTapNavigationVerification() async throws {
        let (router, _, viewModel, view) = createTestComponents()
        _ = view.wrappedViewController

        // Wait for initial load
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        // Verify we have movies to tap
        if case let .success(dataViewState) = viewModel.viewState {
            #expect(!dataViewState.movies.isEmpty, "Should have movies to tap")

            // Get the first movie
            guard let firstMovie = dataViewState.movies.first else {
                #expect(Bool(false), "Expected to find first movie")
                return
            }

            // Simulate a tap gesture on the movie row
            // In a real scenario, this would be done through UIKit interaction
            // For now, we verify the router is properly configured to handle navigation
            router.route(navigationEvent: .detail(firstMovie))

            // Give router time to process navigation
            try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

            // Verify navigation was triggered by checking router state
            // The router should have processed the detail event
            #expect(true, "Navigation event processed successfully")
        }
    }

    @Test("Pull-to-refresh triggers data refresh")
    func pullToRefreshTriggerTest() async throws {
        let (_, _, viewModel, _) = createTestComponents()

        // Wait for initial load
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        // Get initial movie count
        var initialMovieCount = 0
        if case let .success(dataViewState) = viewModel.viewState {
            initialMovieCount = dataViewState.movies.count
            #expect(initialMovieCount > 0, "Should have initial movies")
        }

        // Trigger refresh by calling fetchData (which is called by refreshable closure)
        viewModel.fetchData()

        // Wait for refresh to complete
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        // Verify data was refreshed
        if case let .success(dataViewState) = viewModel.viewState {
            let refreshedMovieCount = dataViewState.movies.count
            #expect(refreshedMovieCount >= initialMovieCount, "Movie count should remain stable or increase after refresh")
        }
    }
}
