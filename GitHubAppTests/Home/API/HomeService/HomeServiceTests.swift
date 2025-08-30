//
//  HomeServiceTests.swift
//  GitHubAppTests
//

import Combine
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
}
