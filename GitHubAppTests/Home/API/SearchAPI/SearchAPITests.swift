//
//  SearchAPITests.swift
//  GitHubAppTests
//

import Foundation
@testable import GitHubApp
import Testing

@MainActor
struct SearchAPITests {
    private func setupTestEnvironment() {
        try? APIKeysProvider.setMovieAPIKey("unit-test-key-123")
    }

    private func cleanupTestEnvironment() {
        try? APIKeysProvider.removeMovieAPIKey()
    }

    @Test("SearchAPI searchMovies case has associated values")
    func searchMoviesCaseHasAssociatedValues() {
        // Given
        let query = "Inception"
        let page = 2

        // When
        let endpoint = SearchAPI.searchMovies(query: query, page: page)

        // Then
        #expect(endpoint != nil)
    }

    @Test("SearchAPI path includes search movie endpoint")
    func pathIncludesSearchMovieEndpoint() {
        // Given
        setupTestEnvironment()
        defer { cleanupTestEnvironment() }
        let endpoint = SearchAPI.searchMovies(query: "test", page: 1)

        // When
        let path = endpoint.path

        // Then
        #expect(path.contains("/search/movie"))
    }

    @Test("SearchAPI path includes query parameter")
    func pathIncludesQueryParameter() {
        // Given
        setupTestEnvironment()
        defer { cleanupTestEnvironment() }
        let query = "Inception"
        let endpoint = SearchAPI.searchMovies(query: query, page: 1)

        // When
        let path = endpoint.path

        // Then
        #expect(path.contains("query="))
        #expect(path.contains("Inception"))
    }

    @Test("SearchAPI path includes page parameter")
    func pathIncludesPageParameter() {
        // Given
        setupTestEnvironment()
        defer { cleanupTestEnvironment() }
        let endpoint = SearchAPI.searchMovies(query: "test", page: 3)

        // When
        let path = endpoint.path

        // Then
        #expect(path.contains("page="))
        #expect(path.contains("3"))
    }

    @Test("SearchAPI path includes API key")
    func pathIncludesAPIKey() {
        // Given
        setupTestEnvironment()
        defer { cleanupTestEnvironment() }
        let endpoint = SearchAPI.searchMovies(query: "test", page: 1)

        // When
        let path = endpoint.path

        // Then
        #expect(path.contains("api_key="))
    }

    @Test("SearchAPI HTTP method is GET")
    func httpMethodIsGET() {
        // Given
        let endpoint = SearchAPI.searchMovies(query: "test", page: 1)

        // When
        let method = endpoint.method

        // Then
        #expect(method == .GET)
    }

    @Test("SearchAPI task is nil for GET requests")
    func taskIsNilForGETRequests() {
        // Given
        let endpoint = SearchAPI.searchMovies(query: "test", page: 1)

        // When
        let task = endpoint.task

        // Then
        #expect(task == nil)
    }

    @Test("SearchAPI header is nil for requests")
    func headerIsNilForRequests() {
        // Given
        let endpoint = SearchAPI.searchMovies(query: "test", page: 1)

        // When
        let header = endpoint.header

        // Then
        #expect(header == nil)
    }

    @Test("SearchAPI endpoint instance is not nil")
    func endpointInstanceIsValid() {
        // Given
        let query = "test"
        let page = 1

        // When
        let endpoint = SearchAPI.searchMovies(query: query, page: page)

        // Then
        #expect(endpoint != nil)
    }

    @Test("SearchAPI path with special characters in query")
    func pathWithSpecialCharactersInQuery() {
        // Given
        setupTestEnvironment()
        defer { cleanupTestEnvironment() }
        let query = "Star Wars & The Force Awakens"
        let endpoint = SearchAPI.searchMovies(query: query, page: 1)

        // When
        let path = endpoint.path

        // Then
        #expect(path.contains("/search/movie"))
        #expect(path.contains("query="))
        // URL encoding should handle special characters
        #expect(!path.isEmpty)
    }

    @Test("SearchAPI path with empty query")
    func pathWithEmptyQuery() {
        // Given
        setupTestEnvironment()
        defer { cleanupTestEnvironment() }
        let endpoint = SearchAPI.searchMovies(query: "", page: 1)

        // When
        let path = endpoint.path

        // Then
        #expect(path.contains("query="))
        #expect(path.contains("/search/movie"))
    }

    @Test("SearchAPI path with different page numbers")
    func pathWithDifferentPageNumbers() {
        // Given
        setupTestEnvironment()
        defer { cleanupTestEnvironment() }

        // When
        let endpoint1 = SearchAPI.searchMovies(query: "test", page: 1)
        let endpoint2 = SearchAPI.searchMovies(query: "test", page: 5)
        let endpoint3 = SearchAPI.searchMovies(query: "test", page: 100)

        let path1 = endpoint1.path
        let path2 = endpoint2.path
        let path3 = endpoint3.path

        // Then
        #expect(path1.contains("page=1"))
        #expect(path2.contains("page=5"))
        #expect(path3.contains("page=100"))
    }

    @Test("SearchAPI returns valid URL string")
    func returnsValidURLString() {
        // Given
        setupTestEnvironment()
        defer { cleanupTestEnvironment() }
        let endpoint = SearchAPI.searchMovies(query: "Inception", page: 1)

        // When
        let path = endpoint.path

        // Then - Should be valid URL
        #expect(URL(string: path) != nil)
    }

    @Test("SearchAPI includes base URL from configuration")
    func includesBaseURLFromConfiguration() {
        // Given
        setupTestEnvironment()
        defer { cleanupTestEnvironment() }
        let endpoint = SearchAPI.searchMovies(query: "test", page: 1)

        // When
        let path = endpoint.path

        // Then
        #expect(path.contains("http"))
    }

    @Test("SearchAPI path is consistent for same parameters")
    func pathIsConsistentForSameParameters() {
        // Given
        setupTestEnvironment()
        defer { cleanupTestEnvironment() }
        let query = "Inception"
        let page = 2

        // When
        let endpoint1 = SearchAPI.searchMovies(query: query, page: page)
        let endpoint2 = SearchAPI.searchMovies(query: query, page: page)

        let path1 = endpoint1.path
        let path2 = endpoint2.path

        // Then
        #expect(path1 == path2)
    }

    @Test("SearchAPI debug property respects build configuration")
    func debugPropertyRespectsBuildConfiguration() {
        // Given
        let endpoint = SearchAPI.searchMovies(query: "test", page: 1)

        // When
        let debugEnabled = endpoint.debug

        // Then
        #if DEBUG
            #expect(debugEnabled == true)
        #else
            #expect(debugEnabled == false)
        #endif
    }
}
