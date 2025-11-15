//
//  MockHomeServiceTests.swift
//  GitHubAppTests
//

import Combine
@testable import GitHubApp
import Testing

@MainActor
struct MockHomeServiceTests {
    @Test("Mock home service fetch movies emits non-empty results")
    func fetchMoviesEmitsResults() async throws {
        let sut = MockHomeService()

        let response = try await sut.fetchMovies().async()
        #expect(!response.results.isEmpty)
    }

    @Test("Mock home service search movies emits non-empty results")
    func searchMoviesEmitsResults() async throws {
        let sut = MockHomeService()

        let response = try await sut.searchMovies(with: "query").async()
        #expect(!response.results.isEmpty)
    }

    @Test("Mock home service fetch credits emits non-empty cast")
    func fetchCreditsEmitsCast() async throws {
        let sut = MockHomeService()

        let response = try await sut.fetchCredits(with: 1).async()
        #expect(!response.cast.isEmpty)
    }

    @Test("Mock home service fetch reviews emits non-empty reviews")
    func fetchReviewsEmitsReviews() async throws {
        let sut = MockHomeService()

        let response = try await sut.fetchReviews(with: 1).async()
        #expect(!response.results.isEmpty)
    }
}
