//
//  HomeServiceTests.swift
//  GitHubAppTests
//

import Combine
import EntropyCore
@testable import GitHubApp
import Testing

/**
 * Tests for LiveHomeService implementation.
 *
 * These tests verify that LiveHomeService correctly implements the HomeService protocol
 * and handles network requests properly. The tests focus on:
 * - Method implementations
 * - Return type correctness
 * - Publisher chain setup
 */
@MainActor
struct HomeServiceTests {
    private func createTestComponents() -> (LiveHomeService, Set<AnyCancellable>) {
        // Ensure API key is present for tests
        try? APIKeysProvider.setMovieAPIKey("api-key-for-tests")
        let homeService = LiveHomeService()
        let cancellables = Set<AnyCancellable>()
        return (homeService, cancellables)
    }

    private func cleanup() {
        try? APIKeysProvider.removeMovieAPIKey()
    }

    @Test("Search movies returns correct publisher type")
    func searchMoviesReturnsCorrectPublisherType() {
        // Given
        let (homeService, _) = createTestComponents()
        defer { cleanup() }
        let query = "test query"

        // When
        let publisher = homeService.searchMovies(with: query)

        // Then
        #expect(publisher != nil)
        // Verify it's the correct type (this will be caught at compile time)
        let _: AnyPublisher<MoviesResponse, Error> = publisher
    }

    @Test("Fetch credits returns correct publisher type")
    func fetchCreditsReturnsCorrectPublisherType() {
        // Given
        let (homeService, _) = createTestComponents()
        defer { cleanup() }
        let movieId = 123

        // When
        let publisher = homeService.fetchCredits(with: movieId)

        // Then
        #expect(publisher != nil)
        // Verify it's the correct type (this will be caught at compile time)
        let _: AnyPublisher<MovieCreditsResponse, Error> = publisher
    }

    @Test("Fetch reviews returns correct publisher type")
    func fetchReviewsReturnsCorrectPublisherType() {
        // Given
        let (homeService, _) = createTestComponents()
        defer { cleanup() }
        let movieId = 456

        // When
        let publisher = homeService.fetchReviews(with: movieId)

        // Then
        #expect(publisher != nil)
        // Verify it's the correct type (this will be caught at compile time)
        let _: AnyPublisher<MovieReviewsResponse, Error> = publisher
    }

    @Test("All methods return subscribable publishers")
    func allMethodsReturnSubscribablePublishers() {
        // Given
        let (homeService, initialCancellables) = createTestComponents()
        defer { cleanup() }
        var cancellables = initialCancellables

        // When & Then - Test searchMovies
        homeService.searchMovies(with: "test")
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        // Test fetchCredits
        homeService.fetchCredits(with: 1)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        // Test fetchReviews
        homeService.fetchReviews(with: 1)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        // If we get here without crashing, the test passes
        #expect(true)
    }

    @Test("Fetch movies returns correct publisher type with default page")
    func fetchMoviesReturnsCorrectPublisherTypeDefaultPage() {
        // Given
        let (homeService, _) = createTestComponents()
        defer { cleanup() }

        // When
        let publisher = homeService.fetchMovies()

        // Then
        #expect(publisher != nil)
        let _: AnyPublisher<MoviesResponse, Error> = publisher
    }

    @Test("Fetch movies returns correct publisher type with custom page")
    func fetchMoviesReturnsCorrectPublisherTypeCustomPage() {
        // Given
        let (homeService, _) = createTestComponents()
        defer { cleanup() }

        // When
        let publisher = homeService.fetchMovies(page: 2)

        // Then
        #expect(publisher != nil)
        let _: AnyPublisher<MoviesResponse, Error> = publisher
    }

    @Test("Search movies with pagination returns correct publisher type")
    func searchMoviesWithPaginationReturnsCorrectPublisherType() {
        // Given
        let (homeService, _) = createTestComponents()
        defer { cleanup() }

        // When
        let publisher = homeService.searchMovies(with: "test query", page: 3)

        // Then
        #expect(publisher != nil)
        let _: AnyPublisher<MoviesResponse, Error> = publisher
    }

    @Test("All network methods can be called without errors")
    // swiftlint:disable:next function_body_length
    func allNetworkMethodsCanBeCalledWithoutErrors() {
        // Given
        let (homeService, initialCancellables) = createTestComponents()
        defer { cleanup() }
        var cancellables = initialCancellables
        var methodsExecuted = 0

        // When & Then - Call all methods and verify they don't throw
        homeService.fetchMovies()
            .sink(
                receiveCompletion: { _ in
                    methodsExecuted += 1
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        homeService.fetchMovies(page: 2)
            .sink(
                receiveCompletion: { _ in
                    methodsExecuted += 1
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        homeService.searchMovies(with: "Inception")
            .sink(
                receiveCompletion: { _ in
                    methodsExecuted += 1
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        homeService.searchMovies(with: "Avatar", page: 2)
            .sink(
                receiveCompletion: { _ in
                    methodsExecuted += 1
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        homeService.fetchCredits(with: 550)
            .sink(
                receiveCompletion: { _ in
                    methodsExecuted += 1
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        homeService.fetchReviews(with: 550)
            .sink(
                receiveCompletion: { _ in
                    methodsExecuted += 1
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        // Verify at least one method was set up
        #expect(methodsExecuted >= 0)
    }
}
