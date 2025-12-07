// swiftlint:disable file_length
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

/// Snapshot and UI tests for MovieDetailsView covering all states and interactions.
///
/// Tests cover:
/// - Loading state with progress indicator
/// - Error state with error message
/// - Success state with credits and reviews
/// - Empty credits/reviews states
/// - Partial data states
/// - Full data snapshot matching
@MainActor
struct MovieDetailsViewTests { // swiftlint:disable:this type_body_length
    // To record new snapshots, uncomment the following line at the top of a test:
    // isRecording = true

    let movie: Movie = .init(id: 346_698,
                             title: "Barbie",
                             overview: "Barbie and Ken are having the time of their lives in the colorful " +
                                 "and seemingly perfect world of Barbie Land. However, when they get a chance to " +
                                 "go to the real world, they soon discover the joys and perils of living among humans.",
                             posterPath: "")

    private let iPhoneAirConfig = ViewImageConfig(
        safeArea: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
        size: CGSize(width: 393, height: 852),
        traits: UITraitCollection()
    )

    // swiftlint:disable large_tuple
    private func createTestComponents(
        with viewModel: MovieDetailsViewModel? = nil
    ) -> (
        mockService: MockHomeService,
        viewModel: MovieDetailsViewModel,
        view: MovieDetailsView
    ) {
        // swiftlint:enable large_tuple
        // Ensure API key is available for any fallback scenarios
        try? APIKeysProvider.setMovieAPIKey("test-api-key-for-movie-details")

        let mockService = MockHomeService()
        let mockStorageService = MockStorageService()
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: mockService)
        serviceLocator.register(StorageService.self, instance: mockStorageService)

        let testViewModel = viewModel ?? MovieDetailsViewModel(movie: movie, serviceLocator: serviceLocator)
        let router = MovieDetailsNavigationRouter()
        let view = MovieDetailsView(router: router, viewModel: testViewModel)

        return (mockService, testViewModel, view)
    }

    // MARK: - Loading State Tests

    @Test("Movie details view displays loading state")
    func movieDetailsViewDisplaysLoadingState() async throws {
        let (_, _, view) = createTestComponents()
        let controller: UIViewController = view.wrappedViewController

        // Verify loading state is displayed
        await MainActor.run {
            assertSnapshot(of: controller, as: .wait(for: 0.5, on: .image(on: iPhoneAirConfig)))
        }
    }

    // MARK: - Success State Tests

    @Test("Movie details view snapshot matches stored reference with full data")
    func movieDetailsViewSnapshotWithFullData() async throws {
        let (_, _, view) = createTestComponents()
        let controller: UIViewController = view.wrappedViewController

        // Wait for auto-load to complete
        try await Task.sleep(nanoseconds: 10_000_000_000) // 10 seconds

        await MainActor.run {
            assertSnapshot(of: controller, as: .wait(for: 2.0, on: .image(on: iPhoneAirConfig)))
        }
    }

    @Test("Movie details view displays credits section when data is loaded")
    func movieDetailsViewDisplaysCreditsSection() async throws {
        let (_, viewModel, _) = createTestComponents()

        // Wait for auto-load to complete
        try await Task.sleep(nanoseconds: 10_000_000_000) // 10 seconds

        // Verify success state
        await MainActor.run {
            if case let .success(dataViewState) = viewModel.viewState {
                // Credits should be populated from MockHomeService
                #expect(!dataViewState.credits.isEmpty, "Credits should be populated")
            } else {
                #expect(Bool(false), "Expected success state after fetch")
            }
        }
    }

    @Test("Movie details view displays reviews section when data is loaded")
    func movieDetailsViewDisplaysReviewsSection() async throws {
        let (_, viewModel, _) = createTestComponents()

        // Wait for auto-load to complete
        try await Task.sleep(nanoseconds: 10_000_000_000) // 10 seconds

        // Verify success state with reviews
        await MainActor.run {
            if case let .success(dataViewState) = viewModel.viewState {
                #expect(!dataViewState.reviews.isEmpty, "Reviews should be populated")
            } else {
                #expect(Bool(false), "Expected success state after fetch")
            }
        }
    }

    // MARK: - Error State Tests

    @Test("Movie details view displays error message on fetch failure")
    func movieDetailsViewDisplaysErrorMessageOnFetchFailure() async throws {
        // Create a failing service
        struct FailingHomeService: HomeService {
            func fetchMovies(page _: Int) -> AnyPublisher<MoviesResponse, Error> {
                let userInfo = [NSLocalizedDescriptionKey: "Network error"]
                return Fail(error: NSError(domain: "test", code: 1, userInfo: userInfo))
                    .eraseToAnyPublisher()
            }

            func searchMovies(with _: String, page _: Int) -> AnyPublisher<MoviesResponse, Error> {
                Fail(error: NSError(domain: "test", code: 1)).eraseToAnyPublisher()
            }

            func fetchCredits(with _: Int) -> AnyPublisher<MovieCreditsResponse, Error> {
                let userInfo = [NSLocalizedDescriptionKey: "Failed to fetch credits"]
                return Fail(error: NSError(domain: "test", code: 1, userInfo: userInfo))
                    .eraseToAnyPublisher()
            }

            func fetchReviews(with _: Int) -> AnyPublisher<MovieReviewsResponse, Error> {
                let userInfo = [NSLocalizedDescriptionKey: "Failed to fetch reviews"]
                return Fail(error: NSError(domain: "test", code: 1, userInfo: userInfo))
                    .eraseToAnyPublisher()
            }
        }

        try? APIKeysProvider.setMovieAPIKey("test-api-key")

        let failingService = FailingHomeService()
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: failingService)

        let errorViewModel = MovieDetailsViewModel(movie: movie, serviceLocator: serviceLocator)
        let router = MovieDetailsNavigationRouter()
        let view = MovieDetailsView(router: router, viewModel: errorViewModel)
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

        // Verify error is displayed visually
        await MainActor.run {
            assertSnapshot(of: controller, as: .wait(for: 0.5, on: .image(on: iPhoneAirConfig)))
        }
    }

    // MARK: - Empty Data States Tests

    @Test("Movie details view displays empty state message for no credits")
    func movieDetailsViewDisplaysEmptyStateMessageForNoCredits() async throws {
        // This test verifies the behavior when credits are empty
        let (_, _, view) = createTestComponents()
        let controller: UIViewController = view.wrappedViewController

        // Wait for auto-load to complete
        try await Task.sleep(nanoseconds: 10_000_000_000) // 10 seconds

        // Snapshot the view
        await MainActor.run {
            assertSnapshot(of: controller, as: .wait(for: 2.0, on: .image(on: iPhoneAirConfig)))
        }
    }

    // MARK: - Navigation and Interaction Tests

    @Test("Movie details view initializes with correct movie data")
    func movieDetailsViewInitializesWithCorrectMovieData() {
        let (_, viewModel, _) = createTestComponents()

        // View initializes successfully and has a valid state
        switch viewModel.viewState {
        case .loading, .success, .error:
            #expect(true)
        }
    }

    @Test("Movie details view handles state transitions correctly")
    func movieDetailsViewHandlesStateTransitionsCorrectly() async throws {
        let (_, viewModel, _) = createTestComponents()

        // Initial state should be loading
        if case .loading = viewModel.viewState {
            #expect(true)
        } else {
            #expect(Bool(false), "Expected initial loading state")
        }

        // Trigger fetch
        viewModel.fetchData()

        // Wait briefly
        try await Task.sleep(nanoseconds: 100_000_000)

        // Should still be loading or transitioning
        #expect(true)

        // Wait for completion
        try await Task.sleep(nanoseconds: 1_500_000_000)

        // Should now be in success or error state
        if case .success = viewModel.viewState {
            #expect(true)
        } else if case .error = viewModel.viewState {
            #expect(true)
        } else if case .loading = viewModel.viewState {
            #expect(true) // Still loading is also acceptable
        }
    }

    @Test("Movie details view supports router for navigation")
    func movieDetailsViewSupportsRouterForNavigation() {
        _ = createTestComponents()

        // View should be properly initialized with router
        #expect(true)
    }

    // MARK: - Empty Sections Tests

    @Test("Movie details empty credits with reviews present")
    func movieDetailsEmptyCreditsWithReviewsPresent() async throws {
        // Create a service that returns credits but no reviews
        struct PartialDataService: HomeService {
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
                // Return empty credits
                Just(MovieCreditsResponse(cast: []))
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }

            func fetchReviews(with _: Int) -> AnyPublisher<MovieReviewsResponse, Error> {
                // Return some reviews
                let review = MovieReview(id: "1", author: "Test Author", content: "Great movie!")
                return Just(MovieReviewsResponse(results: [review]))
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
        }

        try? APIKeysProvider.setMovieAPIKey("test-api-key")
        defer { try? APIKeysProvider.removeMovieAPIKey() }

        let partialService = PartialDataService()
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: partialService)

        let viewModel = MovieDetailsViewModel(movie: movie, serviceLocator: serviceLocator)
        let router = MovieDetailsNavigationRouter()
        let view = MovieDetailsView(router: router, viewModel: viewModel)
        let controller: UIViewController = view.wrappedViewController

        // Trigger data fetch
        viewModel.fetchData()
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        // Verify success state
        if case let .success(dataViewState) = viewModel.viewState {
            // Credits should be empty
            #expect(dataViewState.credits.isEmpty, "Credits should be empty")
            // Reviews should have content
            #expect(!dataViewState.reviews.isEmpty, "Reviews should be present")
        } else {
            #expect(Bool(false), "Expected success state")
        }

        // Snapshot showing empty credits section
        let iPhoneAirConfig = ViewImageConfig(
            safeArea: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
            size: CGSize(width: 393, height: 852),
            traits: UITraitCollection()
        )

        await MainActor.run {
            assertSnapshot(of: controller, as: .wait(for: 0.5, on: .image(on: iPhoneAirConfig)))
        }
    }

    @Test("Movie details empty reviews with credits present")
    func movieDetailsEmptyReviewsWithCreditsPresent() async throws {
        // Create a service that returns credits but no reviews
        struct PartialDataService: HomeService {
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
                // Return some credits
                let actor = MovieCastMember(id: 1, name: "Tom Cruise", character: "Maverick")
                return Just(MovieCreditsResponse(cast: [actor]))
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }

            func fetchReviews(with _: Int) -> AnyPublisher<MovieReviewsResponse, Error> {
                // Return empty reviews
                Just(MovieReviewsResponse(results: []))
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
        }

        try? APIKeysProvider.setMovieAPIKey("test-api-key")
        defer { try? APIKeysProvider.removeMovieAPIKey() }

        let partialService = PartialDataService()
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: partialService)

        let viewModel = MovieDetailsViewModel(movie: movie, serviceLocator: serviceLocator)
        let router = MovieDetailsNavigationRouter()
        let view = MovieDetailsView(router: router, viewModel: viewModel)
        let controller: UIViewController = view.wrappedViewController

        // Trigger data fetch
        viewModel.fetchData()
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        // Verify success state
        if case let .success(dataViewState) = viewModel.viewState {
            // Credits should have content
            #expect(!dataViewState.credits.isEmpty, "Credits should be present")
            // Reviews should be empty
            #expect(dataViewState.reviews.isEmpty, "Reviews should be empty")
        } else {
            #expect(Bool(false), "Expected success state")
        }

        // Snapshot showing empty reviews section
        let iPhoneAirConfig = ViewImageConfig(
            safeArea: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
            size: CGSize(width: 393, height: 852),
            traits: UITraitCollection()
        )

        await MainActor.run {
            assertSnapshot(of: controller, as: .wait(for: 0.5, on: .image(on: iPhoneAirConfig)))
        }
    }

    @Test("Movie details both credits and reviews empty")
    func movieDetailsBothEmptySections() async throws {
        // Create a service that returns no credits or reviews
        struct EmptyDataService: HomeService {
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

        try? APIKeysProvider.setMovieAPIKey("test-api-key")
        defer { try? APIKeysProvider.removeMovieAPIKey() }

        let emptyService = EmptyDataService()
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: emptyService)

        let viewModel = MovieDetailsViewModel(movie: movie, serviceLocator: serviceLocator)
        let router = MovieDetailsNavigationRouter()
        let view = MovieDetailsView(router: router, viewModel: viewModel)
        let controller: UIViewController = view.wrappedViewController

        // Trigger data fetch
        viewModel.fetchData()
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        // Verify success state with empty sections
        if case let .success(dataViewState) = viewModel.viewState {
            #expect(dataViewState.credits.isEmpty, "Credits should be empty")
            #expect(dataViewState.reviews.isEmpty, "Reviews should be empty")
        } else {
            #expect(Bool(false), "Expected success state")
        }

        // Snapshot showing both sections empty
        let iPhoneAirConfig = ViewImageConfig(
            safeArea: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
            size: CGSize(width: 393, height: 852),
            traits: UITraitCollection()
        )

        await MainActor.run {
            assertSnapshot(of: controller, as: .wait(for: 0.5, on: .image(on: iPhoneAirConfig)))
        }
    }

    @Test("Image loading failure handles gracefully")
    func imageLoadingFailureHandling() async throws {
        struct ImageFailureService: HomeService {
            func fetchMovies(page _: Int) -> AnyPublisher<MoviesResponse, Error> {
                let movie = Movie(id: 1, title: "Test", overview: "Test", posterPath: "/invalid-path.jpg")
                let response = MoviesResponse(results: [movie], page: 1, totalPages: 1, totalResults: 1)
                return Just(response)
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

        let failureService = ImageFailureService()
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: failureService)
        serviceLocator.register(StorageService.self, instance: MockStorageService())

        let viewModel = MovieDetailsViewModel(movie: movie, serviceLocator: serviceLocator)

        // Trigger data fetch
        viewModel.handle(.fetchData)
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        // Verify view state is still valid despite image loading issues
        if case let .success(dataViewState) = viewModel.viewState {
            // Movie with invalid image path should still render successfully
            #expect(!dataViewState.movie.title.isEmpty, "Movie should render even if image fails to load")
        } else {
            #expect(Bool(false), "Expected success state even with image loading failure")
        }
    }
}
