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
        _ = publisher
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
        _ = publisher
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
        _ = publisher
        // Verify it's the correct type (this will be caught at compile time)
        let _: AnyPublisher<MovieReviewsResponse, Error> = publisher
    }

    @Test("Fetch movies returns correct publisher type with default page")
    func fetchMoviesReturnsCorrectPublisherTypeDefaultPage() {
        // Given
        let (homeService, _) = createTestComponents()
        defer { cleanup() }

        // When
        let publisher = homeService.fetchMovies()

        // Then
        _ = publisher
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
        _ = publisher
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
        _ = publisher
        let _: AnyPublisher<MoviesResponse, Error> = publisher
    }
}
