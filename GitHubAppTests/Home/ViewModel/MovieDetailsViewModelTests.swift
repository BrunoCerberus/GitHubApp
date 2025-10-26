//
//  MovieDetailsViewModelTests.swift
//  GitHubAppTests
//

import Combine
import Foundation
@testable import GitHubApp
import Testing

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
}
