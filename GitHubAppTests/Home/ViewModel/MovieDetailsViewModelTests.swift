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
        StorageServiceFactory.shared.resetCache()
        StorageServiceFactory.shared.updateConfiguration(.testing)
        try? APIKeysProvider.setMovieAPIKey("md-key")
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: service)
        let movie = Movie(id: 999, title: "T", overview: "O", posterPath: nil)
        return MovieDetailsViewModel(movie: movie, serviceLocator: serviceLocator)
    }

    private func cleanupTest() {
        StorageServiceFactory.shared.resetCache()
        StorageServiceFactory.shared.updateConfiguration(.production)
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
        #expect(!sut.data.credits.isEmpty)
        #expect(!sut.data.reviews.isEmpty)
    }

    @Test("Error handling sets error")
    func errorHandlingSetsError() async throws {
        defer { cleanupTest() }

        // Given
        struct FailingService: HomeService {
            func fetchMovies() -> AnyPublisher<MoviesResponse, Error> {
                Fail(error: NSError(domain: "e", code: 1)).eraseToAnyPublisher()
            }

            func searchMovies(with _: String) -> AnyPublisher<MoviesResponse, Error> {
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
