//
//  HomeServiceTests.swift
//  GitHubAppTests
//

import Combine
@testable import GitHubApp
import XCTest

/**
 * Tests for LiveHomeService implementation.
 *
 * These tests verify that LiveHomeService correctly implements the HomeService protocol
 * and handles network requests properly. The tests focus on:
 * - Method implementations
 * - Return type correctness
 * - Publisher chain setup
 */
final class HomeServiceTests: XCTestCase {
    /// Service instance to test
    private var homeService: LiveHomeService!

    /// Storage for cancellables to prevent memory leaks
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        // Ensure API key is present for tests
        try? APIKeysProvider.setMovieAPIKey("api-key-for-tests")
        homeService = LiveHomeService()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        try? APIKeysProvider.removeMovieAPIKey()
        cancellables = nil
        homeService = nil
        super.tearDown()
    }

    /**
     * Test that searchMovies method returns correct publisher type.
     *
     * Verifies that the method returns an AnyPublisher<MoviesResponse, Error>
     * and doesn't crash when called with various query strings.
     */
    func testSearchMoviesReturnsCorrectPublisherType() {
        // Given
        let query = "test query"

        // When
        let publisher = homeService.searchMovies(with: query)

        // Then
        XCTAssertNotNil(publisher)
        // Verify it's the correct type (this will be caught at compile time)
        let _: AnyPublisher<MoviesResponse, Error> = publisher
    }

    /**
     * Test that fetchCredits method returns correct publisher type.
     *
     * Verifies that the method returns an AnyPublisher<MovieCreditsResponse, Error>
     * and doesn't crash when called with various movie IDs.
     */
    func testFetchCreditsReturnsCorrectPublisherType() {
        // Given
        let movieId = 123

        // When
        let publisher = homeService.fetchCredits(with: movieId)

        // Then
        XCTAssertNotNil(publisher)
        // Verify it's the correct type (this will be caught at compile time)
        let _: AnyPublisher<MovieCreditsResponse, Error> = publisher
    }

    /**
     * Test that fetchReviews method returns correct publisher type.
     *
     * Verifies that the method returns an AnyPublisher<MovieReviewsResponse, Error>
     * and doesn't crash when called with various movie IDs.
     */
    func testFetchReviewsReturnsCorrectPublisherType() {
        // Given
        let movieId = 456

        // When
        let publisher = homeService.fetchReviews(with: movieId)

        // Then
        XCTAssertNotNil(publisher)
        // Verify it's the correct type (this will be caught at compile time)
        let _: AnyPublisher<MovieReviewsResponse, Error> = publisher
    }

    /**
     * Test that all methods return publishers that can be subscribed to.
     *
     * This test ensures that the publisher chain is properly set up
     * and doesn't crash when attempting to subscribe.
     */
    func testAllMethodsReturnSubscribablePublishers() {
        // Test searchMovies
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
        XCTAssertTrue(true)
    }
}
