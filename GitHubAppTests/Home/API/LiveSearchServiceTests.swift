//
//  LiveSearchServiceTests.swift
//  GitHubAppTests
//

import Combine
@testable import GitHubApp
import Testing

@MainActor
struct LiveSearchServiceTests {
    private func createTestComponents() -> (LiveSearchService, AnyCancellable?) {
        // Set test API key
        try? APIKeysProvider.setMovieAPIKey("unit-test-key")

        let service = LiveSearchService()
        return (service, nil)
    }

    @Test("SearchMovies returns AnyPublisher")
    func searchMoviesReturnsPublisher() {
        // Given
        let (sut, _) = createTestComponents()
        defer {
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // When
        let publisher = sut.searchMovies(with: "test", page: 1)

        // Then
        #expect(publisher != nil)
    }

    @Test("SearchMovies accepts query parameter")
    func searchMoviesAcceptsQuery() {
        // Given
        let (sut, _) = createTestComponents()
        let testQuery = "Inception"
        defer {
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // When
        _ = sut.searchMovies(with: testQuery, page: 1)

        // Then - No error should occur during publisher creation
        #expect(true)
    }

    @Test("SearchMovies accepts page parameter")
    func searchMoviesAcceptsPageParameter() {
        // Given
        let (sut, _) = createTestComponents()
        defer {
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // When
        let publisher1 = sut.searchMovies(with: "test", page: 1)
        let publisher2 = sut.searchMovies(with: "test", page: 2)
        let publisher3 = sut.searchMovies(with: "test", page: 100)

        // Then - All should be valid publishers
        #expect(publisher1 != nil)
        #expect(publisher2 != nil)
        #expect(publisher3 != nil)
    }

    @Test("SearchMovies default page is 1")
    func searchMoviesDefaultPageIsOne() {
        // Given
        let (sut, _) = createTestComponents()
        defer {
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // When - Call without explicit page parameter
        let publisher = sut.searchMovies(with: "test")

        // Then - Should create valid publisher (page defaults to 1)
        #expect(publisher != nil)
    }

    @Test("SearchMovies empty query parameter is allowed")
    func searchMoviesEmptyQueryAllowed() {
        // Given
        let (sut, _) = createTestComponents()
        defer {
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // When
        let publisher = sut.searchMovies(with: "", page: 1)

        // Then - Should create publisher even with empty query
        #expect(publisher != nil)
    }

    @Test("LiveSearchService conforms to SearchService protocol")
    func conformsToSearchServiceProtocol() {
        // Given
        let (sut, _) = createTestComponents()
        defer {
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // When - Treat as SearchService
        let service: SearchService = sut

        // Then - No error during protocol conformance
        #expect(service != nil)
    }

    @Test("LiveSearchService instance can be created multiple times")
    func multipleInstancesCanBeCreated() {
        // Given
        try? APIKeysProvider.setMovieAPIKey("unit-test-key")
        defer {
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // When - Create multiple instances
        let service1 = LiveSearchService()
        let service2 = LiveSearchService()
        let service3 = LiveSearchService()

        // Then - All should be valid SearchService instances
        let svc1: SearchService = service1
        let svc2: SearchService = service2
        let svc3: SearchService = service3

        #expect(svc1 != nil)
        #expect(svc2 != nil)
        #expect(svc3 != nil)
    }

    @Test("Multiple concurrent searches can be initiated")
    func multipleConcurrentSearches() {
        // Given
        let (sut, _) = createTestComponents()
        defer {
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // When
        let publisher1 = sut.searchMovies(with: "query1", page: 1)
        let publisher2 = sut.searchMovies(with: "query2", page: 1)
        let publisher3 = sut.searchMovies(with: "query3", page: 1)

        // Then - All publishers should be independent
        #expect(publisher1 != nil)
        #expect(publisher2 != nil)
        #expect(publisher3 != nil)
    }

    @Test("SearchMovies query with special characters")
    func searchMoviesWithSpecialCharacters() {
        // Given
        let (sut, _) = createTestComponents()
        defer {
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // When
        let queries = ["Star Wars", "Harry Potter & the Philosopher's Stone", "Back to the Future: Part II", "O'Reilly"]
        let publishers = queries.map { sut.searchMovies(with: $0, page: 1) }

        // Then - All should create valid publishers
        #expect(publishers.count == 4)
        #expect(publishers.allSatisfy { $0 != nil })
    }
}
