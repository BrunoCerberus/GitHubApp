//
//  MovieDetailsViewModelTests.swift
//  GitHubAppTests
//

import Combine
import Foundation
@testable import GitHubApp
import Testing

@Suite(.serialized)
@MainActor
struct MovieDetailsViewModelTests {
    private func createTestComponents(with service: HomeService) -> MovieDetailsViewModel {
        try? APIKeysProvider.setMovieAPIKey("md-key")
        let mockStorageService = MockStorageService()

        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: service)
        serviceLocator.register(StorageService.self, instance: mockStorageService)

        let movie = Movie(id: 999, title: "T", overview: "O", posterPath: nil)
        return MovieDetailsViewModel(movie: movie, serviceLocator: serviceLocator)
    }

    private func cleanupTest() {
        try? APIKeysProvider.removeMovieAPIKey()
    }

    @Test("Fetch data sets credits and reviews")
    func fetchDataSetsCreditsAndReviews() async throws {
        defer { cleanupTest() }

        // Given
        let sut = createTestComponents(with: MockHomeService())

        // When
        sut.fetchData()

        // Wait for async operations
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then
        if case let .success(dataViewState) = sut.viewState {
            #expect(!dataViewState.credits.isEmpty)
            #expect(!dataViewState.reviews.isEmpty)
        } else {
            #expect(false, "Expected success state but got \(sut.viewState)")
        }
    }

    @Test("Error handling sets error")
    func errorHandlingSetsError() async throws {
        defer { cleanupTest() }

        // Given
        struct FailingService: HomeService {
            func fetchMovies(page _: Int) -> AnyPublisher<MoviesResponse, Error> {
                Fail(error: NSError(domain: "e", code: 1)).eraseToAnyPublisher()
            }

            func searchMovies(with _: String, page _: Int) -> AnyPublisher<MoviesResponse, Error> {
                Fail(error: NSError(domain: "e", code: 1)).eraseToAnyPublisher()
            }

            func fetchCredits(with _: Int) -> AnyPublisher<MovieCreditsResponse, Error> {
                Fail(error: NSError(domain: "e", code: 1)).eraseToAnyPublisher()
            }

            func fetchReviews(with _: Int) -> AnyPublisher<MovieReviewsResponse, Error> {
                Fail(error: NSError(domain: "e", code: 1)).eraseToAnyPublisher()
            }
        }

        let sut = createTestComponents(with: FailingService())

        // When
        sut.fetchData()

        // Wait for async operations
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then
        #expect(sut.error != nil)
    }

    @Test("Initial state is loading")
    func initialStateIsLoading() {
        defer { cleanupTest() }

        // Given/When
        let sut = createTestComponents(with: MockHomeService())

        // Then - Initial state should be loading
        if case .loading = sut.viewState {
            #expect(true)
        } else {
            #expect(false, "Expected loading state but got \(sut.viewState)")
        }
    }

    @Test("Toggle favorite adds movie to favorites")
    func toggleFavoriteAddsMovieToFavorites() async throws {
        defer { cleanupTest() }

        // Given
        let mockStorageService = MockStorageService()
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: MockHomeService())
        serviceLocator.register(StorageService.self, instance: mockStorageService)

        let movie = Movie(id: 1, title: "Test Movie", overview: "Test", posterPath: nil)
        let sut = MovieDetailsViewModel(movie: movie, serviceLocator: serviceLocator)

        // Wait for initial load
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

        // When
        sut.toggleFavorite(for: movie)

        // Wait for toggle to complete
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

        // Then
        #expect(sut.isFavorited(movie: movie), "Movie should be favorited")
        #expect(sut.favoriteMovies.contains(where: { $0.id == movie.id }), "Favorite movies should contain the movie")
    }

    @Test("Toggle favorite twice removes movie from favorites")
    func toggleFavoriteTwiceRemovesMovieFromFavorites() async throws {
        defer { cleanupTest() }

        // Given
        let mockStorageService = MockStorageService()
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: MockHomeService())
        serviceLocator.register(StorageService.self, instance: mockStorageService)

        let movie = Movie(id: 2, title: "Toggle Test", overview: "Test", posterPath: nil)
        let sut = MovieDetailsViewModel(movie: movie, serviceLocator: serviceLocator)

        // Wait for initial load
        try await Task.sleep(nanoseconds: 300_000_000)

        // When - Toggle on then off
        sut.toggleFavorite(for: movie)
        try await Task.sleep(nanoseconds: 300_000_000)

        sut.toggleFavorite(for: movie)
        try await Task.sleep(nanoseconds: 300_000_000)

        // Then
        #expect(!sut.isFavorited(movie: movie), "Movie should not be favorited")
        #expect(sut.favoriteMovies.isEmpty, "Favorite movies should be empty")
    }

    @Test("Is favorited returns false for non-favorite movie")
    func isFavoritedReturnsFalseForNonFavoriteMovie() async throws {
        defer { cleanupTest() }

        // Given
        let sut = createTestComponents(with: MockHomeService())

        // Wait for initial load
        try await Task.sleep(nanoseconds: 300_000_000)

        let nonFavoriteMovie = Movie(id: 999, title: "Not Favorited", overview: "Test", posterPath: nil)

        // When/Then
        #expect(!sut.isFavorited(movie: nonFavoriteMovie), "Non-favorite movie should return false")
    }

    @Test("Is favorited returns false when in loading state")
    func isFavoritedReturnsFalseWhenInLoadingState() {
        defer { cleanupTest() }

        // Given
        let sut = createTestComponents(with: MockHomeService())

        // Immediately check before state transitions
        let movie = Movie(id: 1, title: "Test", overview: "Test", posterPath: nil)

        // When/Then - In loading state
        #expect(!sut.isFavorited(movie: movie), "Should return false in loading state")
    }

    @Test("Is favorited returns false when in error state")
    func isFavoritedReturnsFalseWhenInErrorState() async throws {
        defer { cleanupTest() }

        // Given
        struct FailingService: HomeService {
            func fetchMovies(page _: Int) -> AnyPublisher<MoviesResponse, Error> {
                Fail(error: NSError(domain: "e", code: 1)).eraseToAnyPublisher()
            }

            func searchMovies(with _: String, page _: Int) -> AnyPublisher<MoviesResponse, Error> {
                Fail(error: NSError(domain: "e", code: 1)).eraseToAnyPublisher()
            }

            func fetchCredits(with _: Int) -> AnyPublisher<MovieCreditsResponse, Error> {
                Fail(error: NSError(domain: "e", code: 1)).eraseToAnyPublisher()
            }

            func fetchReviews(with _: Int) -> AnyPublisher<MovieReviewsResponse, Error> {
                Fail(error: NSError(domain: "e", code: 1)).eraseToAnyPublisher()
            }
        }

        let sut = createTestComponents(with: FailingService())

        // Wait for error state
        try await Task.sleep(nanoseconds: 300_000_000)

        let movie = Movie(id: 1, title: "Test", overview: "Test", posterPath: nil)

        // When/Then - In error state
        #expect(!sut.isFavorited(movie: movie), "Should return false in error state")
    }

    @Test("Favorite movies returns empty array when in loading state")
    func favoriteMoviesReturnsEmptyArrayWhenInLoadingState() {
        defer { cleanupTest() }

        // Given
        let sut = createTestComponents(with: MockHomeService())

        // When/Then - In loading state
        #expect(sut.favoriteMovies.isEmpty, "Should return empty array in loading state")
    }

    @Test("Favorite movies returns empty array when in error state")
    func favoriteMoviesReturnsEmptyArrayWhenInErrorState() async throws {
        defer { cleanupTest() }

        // Given
        struct FailingService: HomeService {
            func fetchMovies(page _: Int) -> AnyPublisher<MoviesResponse, Error> {
                Fail(error: NSError(domain: "e", code: 1)).eraseToAnyPublisher()
            }

            func searchMovies(with _: String, page _: Int) -> AnyPublisher<MoviesResponse, Error> {
                Fail(error: NSError(domain: "e", code: 1)).eraseToAnyPublisher()
            }

            func fetchCredits(with _: Int) -> AnyPublisher<MovieCreditsResponse, Error> {
                Fail(error: NSError(domain: "e", code: 1)).eraseToAnyPublisher()
            }

            func fetchReviews(with _: Int) -> AnyPublisher<MovieReviewsResponse, Error> {
                Fail(error: NSError(domain: "e", code: 1)).eraseToAnyPublisher()
            }
        }

        let sut = createTestComponents(with: FailingService())

        // Wait for error state
        try await Task.sleep(nanoseconds: 300_000_000)

        // When/Then - In error state
        #expect(sut.favoriteMovies.isEmpty, "Should return empty array in error state")
    }

    @Test("Error property returns nil when in success state")
    func errorPropertyReturnsNilWhenInSuccessState() async throws {
        defer { cleanupTest() }

        // Given
        let sut = createTestComponents(with: MockHomeService())

        // Wait for success state
        try await Task.sleep(nanoseconds: 300_000_000)

        // When/Then
        #expect(sut.error == nil, "Should return nil in success state")
    }

    @Test("Error property returns nil when in loading state")
    func errorPropertyReturnsNilWhenInLoadingState() {
        defer { cleanupTest() }

        // Given
        let sut = createTestComponents(with: MockHomeService())

        // When/Then - In loading state
        #expect(sut.error == nil, "Should return nil in loading state")
    }

    @Test("Error property returns error message when in error state")
    func errorPropertyReturnsErrorMessageWhenInErrorState() async throws {
        defer { cleanupTest() }

        // Given
        struct FailingService: HomeService {
            func fetchMovies(page _: Int) -> AnyPublisher<MoviesResponse, Error> {
                Fail(error: NSError(domain: "e", code: 1)).eraseToAnyPublisher()
            }

            func searchMovies(with _: String, page _: Int) -> AnyPublisher<MoviesResponse, Error> {
                Fail(error: NSError(domain: "e", code: 1)).eraseToAnyPublisher()
            }

            func fetchCredits(with _: Int) -> AnyPublisher<MovieCreditsResponse, Error> {
                Fail(error: NSError(domain: "e", code: 1)).eraseToAnyPublisher()
            }

            func fetchReviews(with _: Int) -> AnyPublisher<MovieReviewsResponse, Error> {
                Fail(error: NSError(domain: "e", code: 1)).eraseToAnyPublisher()
            }
        }

        let sut = createTestComponents(with: FailingService())

        // Wait for error state
        try await Task.sleep(nanoseconds: 300_000_000)

        // When/Then
        #expect(sut.error != nil, "Should return error message in error state")
        #expect(!sut.error!.isEmpty, "Error message should not be empty")
    }

    @Test("Send view event delegates to handle method")
    func sendViewEventDelegatesToHandle() async throws {
        defer { cleanupTest() }

        // Given
        let sut = createTestComponents(with: MockHomeService())

        // When
        sut.sendViewEvent(.fetchData)

        // Wait for processing
        try await Task.sleep(nanoseconds: 300_000_000)

        // Then - Should process event and update state
        if case .success = sut.viewState {
            #expect(true)
        } else {
            #expect(false, "Expected success state after sending fetchData event")
        }
    }

    @Test("View model handles multiple rapid toggle favorite calls")
    func viewModelHandlesMultipleRapidToggleFavoriteCalls() async throws {
        defer { cleanupTest() }

        // Given
        let mockStorageService = MockStorageService()
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: MockHomeService())
        serviceLocator.register(StorageService.self, instance: mockStorageService)

        let movie = Movie(id: 100, title: "Rapid Toggle", overview: "Test", posterPath: nil)
        let sut = MovieDetailsViewModel(movie: movie, serviceLocator: serviceLocator)

        // Wait for initial load
        try await Task.sleep(nanoseconds: 300_000_000)

        // When - Rapid toggles
        sut.toggleFavorite(for: movie)
        sut.toggleFavorite(for: movie)
        sut.toggleFavorite(for: movie)

        // Wait for all toggles to complete
        try await Task.sleep(nanoseconds: 500_000_000)

        // Then - Should handle all toggles (odd number = favorited)
        #expect(sut.isFavorited(movie: movie), "After 3 toggles, should be favorited")
    }
}
