//
//  MockHomeServiceTests.swift
//  GitHubAppTests
//

import Combine
import Foundation
@testable import GitHubApp
import Testing

/**
 * Comprehensive unit tests for MockHomeService.
 *
 * Tests cover:
 * - Fetching movies with pagination
 * - Searching movies
 * - Fetching movie credits
 * - Fetching movie reviews
 * - Response data validation
 * - Main thread delivery
 */
@MainActor
struct MockHomeServiceTests {
    // MARK: - Fetch Movies Tests

    @Test("Mock home service fetch movies emits non-empty results")
    func fetchMoviesEmitsResults() async throws {
        let sut = MockHomeService()

        let response = try await sut.fetchMovies().async()
        #expect(!response.results.isEmpty)
    }

    @Test("Fetch movies returns correct number of results")
    func fetchMoviesReturnsCorrectNumberOfResults() async throws {
        // Given
        let service = MockHomeService()

        // When
        let response = try await service.fetchMovies().async()

        // Then
        #expect(response.results.count == 3, "Should return 3 mock movies")
    }

    @Test("Fetch movies with default page returns page 1")
    func fetchMoviesWithDefaultPageReturnsPage1() async throws {
        // Given
        let service = MockHomeService()

        // When
        let response = try await service.fetchMovies().async()

        // Then
        #expect(response.page == 1, "Should return page 1")
    }

    @Test("Fetch movies with custom page returns correct page")
    func fetchMoviesWithCustomPageReturnsCorrectPage() async throws {
        // Given
        let service = MockHomeService()

        // When
        let response = try await service.fetchMovies(page: 5).async()

        // Then
        #expect(response.page == 5, "Should return requested page")
    }

    @Test("Fetch movies returns correct pagination info")
    func fetchMoviesReturnsCorrectPaginationInfo() async throws {
        // Given
        let service = MockHomeService()

        // When
        let response = try await service.fetchMovies().async()

        // Then
        #expect(response.totalPages == 10, "Should have 10 total pages")
        #expect(response.totalResults == 30, "Should have 30 total results (3 × 10)")
    }

    @Test("Fetch movies returns valid movie data")
    func fetchMoviesReturnsValidMovieData() async throws {
        // Given
        let service = MockHomeService()

        // When
        let response = try await service.fetchMovies().async()

        // Then
        let firstMovie = response.results.first!
        #expect(firstMovie.id == 346_698, "Should have correct movie ID")
        #expect(firstMovie.title == "Barbie", "Should have correct movie title")
        #expect(!firstMovie.overview.isEmpty, "Should have overview")
    }

    @Test("Fetch movies delivers on main thread")
    func fetchMoviesDeliversOnMainThread() async throws {
        // Given
        let service = MockHomeService()
        var receivedOnMainThread = false

        // When
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation()

        service.fetchMovies()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { _ in
                    receivedOnMainThread = Thread.isMainThread
                }
            )
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 1.0)

        // Then
        #expect(receivedOnMainThread, "Should deliver on main thread")
    }

    // MARK: - Search Movies Tests

    @Test("Mock home service search movies emits non-empty results")
    func searchMoviesEmitsResults() async throws {
        let sut = MockHomeService()

        let response = try await sut.searchMovies(with: "query").async()
        #expect(!response.results.isEmpty)
    }

    @Test("Search movies returns correct number of results")
    func searchMoviesReturnsCorrectNumberOfResults() async throws {
        // Given
        let service = MockHomeService()

        // When
        let response = try await service.searchMovies(with: "test").async()

        // Then
        #expect(response.results.count == 3, "Should return 3 mock movies")
    }

    @Test("Search movies with empty query returns results")
    func searchMoviesWithEmptyQueryReturnsResults() async throws {
        // Given
        let service = MockHomeService()

        // When
        let response = try await service.searchMovies(with: "").async()

        // Then
        #expect(!response.results.isEmpty, "Should return results even with empty query")
    }

    @Test("Search movies with custom page returns correct page")
    func searchMoviesWithCustomPageReturnsCorrectPage() async throws {
        // Given
        let service = MockHomeService()

        // When
        let response = try await service.searchMovies(with: "test", page: 3).async()

        // Then
        #expect(response.page == 3, "Should return requested page")
    }

    @Test("Search movies returns correct pagination info")
    func searchMoviesReturnsCorrectPaginationInfo() async throws {
        // Given
        let service = MockHomeService()

        // When
        let response = try await service.searchMovies(with: "test").async()

        // Then
        #expect(response.totalPages == 5, "Should have 5 total pages")
        #expect(response.totalResults == 15, "Should have 15 total results (3 × 5)")
    }

    @Test("Search movies delivers on main thread")
    func searchMoviesDeliversOnMainThread() async throws {
        // Given
        let service = MockHomeService()
        var receivedOnMainThread = false

        // When
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation()

        service.searchMovies(with: "test")
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { _ in
                    receivedOnMainThread = Thread.isMainThread
                }
            )
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 1.0)

        // Then
        #expect(receivedOnMainThread, "Should deliver on main thread")
    }

    // MARK: - Fetch Credits Tests

    @Test("Mock home service fetch credits emits non-empty cast")
    func fetchCreditsEmitsCast() async throws {
        let sut = MockHomeService()

        let response = try await sut.fetchCredits(with: 1).async()
        #expect(!response.cast.isEmpty)
    }

    @Test("Fetch credits returns correct number of cast members")
    func fetchCreditsReturnsCorrectNumberOfCastMembers() async throws {
        // Given
        let service = MockHomeService()

        // When
        let response = try await service.fetchCredits(with: 1).async()

        // Then
        #expect(response.cast.count == 3, "Should return 3 cast members")
    }

    @Test("Fetch credits returns valid cast member data")
    func fetchCreditsReturnsValidCastMemberData() async throws {
        // Given
        let service = MockHomeService()

        // When
        let response = try await service.fetchCredits(with: 1).async()

        // Then
        let firstCast = response.cast.first!
        #expect(firstCast.id == 234_352, "Should have correct cast ID")
        #expect(firstCast.name == "Margot Robbie", "Should have correct name")
        #expect(firstCast.character == "Barbie", "Should have correct character")
    }

    @Test("Fetch credits with different movie IDs returns same data")
    func fetchCreditsWithDifferentMovieIDsReturnsSameData() async throws {
        // Given
        let service = MockHomeService()

        // When
        let response1 = try await service.fetchCredits(with: 1).async()
        let response2 = try await service.fetchCredits(with: 999).async()

        // Then
        #expect(response1.cast.count == response2.cast.count, "Should return same mock data")
    }

    @Test("Fetch credits delivers on main thread")
    func fetchCreditsDeliversOnMainThread() async throws {
        // Given
        let service = MockHomeService()
        var receivedOnMainThread = false

        // When
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation()

        service.fetchCredits(with: 1)
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { _ in
                    receivedOnMainThread = Thread.isMainThread
                }
            )
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 1.0)

        // Then
        #expect(receivedOnMainThread, "Should deliver on main thread")
    }

    // MARK: - Fetch Reviews Tests

    @Test("Mock home service fetch reviews emits non-empty reviews")
    func fetchReviewsEmitsReviews() async throws {
        let sut = MockHomeService()

        let response = try await sut.fetchReviews(with: 1).async()
        #expect(!response.results.isEmpty)
    }

    @Test("Fetch reviews returns correct number of reviews")
    func fetchReviewsReturnsCorrectNumberOfReviews() async throws {
        // Given
        let service = MockHomeService()

        // When
        let response = try await service.fetchReviews(with: 1).async()

        // Then
        #expect(response.results.count == 3, "Should return 3 reviews")
    }

    @Test("Fetch reviews returns valid review data")
    func fetchReviewsReturnsValidReviewData() async throws {
        // Given
        let service = MockHomeService()

        // When
        let response = try await service.fetchReviews(with: 1).async()

        // Then
        let firstReview = response.results.first!
        #expect(firstReview.id == "64bb00dc357c00021de27485", "Should have correct review ID")
        #expect(firstReview.author == "Chris Sawin", "Should have correct author")
        #expect(!firstReview.content.isEmpty, "Should have content")
    }

    @Test("Fetch reviews with different movie IDs returns same data")
    func fetchReviewsWithDifferentMovieIDsReturnsSameData() async throws {
        // Given
        let service = MockHomeService()

        // When
        let response1 = try await service.fetchReviews(with: 1).async()
        let response2 = try await service.fetchReviews(with: 999).async()

        // Then
        #expect(response1.results.count == response2.results.count, "Should return same mock data")
    }

    @Test("Fetch reviews delivers on main thread")
    func fetchReviewsDeliversOnMainThread() async throws {
        // Given
        let service = MockHomeService()
        var receivedOnMainThread = false

        // When
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation()

        service.fetchReviews(with: 1)
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { _ in
                    receivedOnMainThread = Thread.isMainThread
                }
            )
            .store(in: &cancellables)

        await expectation.waitForFulfillment(timeout: 1.0)

        // Then
        #expect(receivedOnMainThread, "Should deliver on main thread")
    }

    // MARK: - All Movies Data Tests

    @Test("All mock movies have valid IDs")
    func allMockMoviesHaveValidIDs() async throws {
        // Given
        let service = MockHomeService()

        // When
        let response = try await service.fetchMovies().async()

        // Then
        for movie in response.results {
            #expect(movie.id > 0, "All movies should have valid IDs")
        }
    }

    @Test("All mock movies have titles")
    func allMockMoviesHaveTitles() async throws {
        // Given
        let service = MockHomeService()

        // When
        let response = try await service.fetchMovies().async()

        // Then
        for movie in response.results {
            #expect(!movie.title.isEmpty, "All movies should have titles")
        }
    }

    @Test("All mock cast members have names and characters")
    func allMockCastMembersHaveNamesAndCharacters() async throws {
        // Given
        let service = MockHomeService()

        // When
        let response = try await service.fetchCredits(with: 1).async()

        // Then
        for cast in response.cast {
            #expect(!cast.name.isEmpty, "All cast members should have names")
            #expect(!cast.character.isEmpty, "All cast members should have characters")
        }
    }

    @Test("All mock reviews have authors and content")
    func allMockReviewsHaveAuthorsAndContent() async throws {
        // Given
        let service = MockHomeService()

        // When
        let response = try await service.fetchReviews(with: 1).async()

        // Then
        for review in response.results {
            #expect(!review.author.isEmpty, "All reviews should have authors")
            #expect(!review.content.isEmpty, "All reviews should have content")
        }
    }
}

/**
 * Helper for async testing expectations.
 */
private func expectation() -> TestExpectation {
    TestExpectation()
}

private final class TestExpectation: @unchecked Sendable {
    private var fulfilled = false

    func fulfill() {
        fulfilled = true
    }

    func waitForFulfillment(timeout: TimeInterval) async {
        let deadline = Date().addingTimeInterval(timeout)
        while !fulfilled, Date() < deadline {
            try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
        }
    }
}
