//
//  SearchDomainInteractorTests.swift
//  GitHubAppTests
//

import Combine
@testable import GitHubApp
import Testing

@MainActor
struct SearchDomainInteractorTests {
    private func createTestComponents() -> (SearchDomainInteractor, MockSearchService, StorageService) {
        let mockSearchService = MockSearchService()
        let mockStorageService = MockStorageService()

        let serviceLocator = ServiceLocator()
        serviceLocator.register(SearchService.self, instance: mockSearchService)
        serviceLocator.register(StorageService.self, instance: mockStorageService)

        let interactor = SearchDomainInteractor(serviceLocator: serviceLocator)
        // Ensure API key exists in case anything inadvertently touches SearchAPI
        try? APIKeysProvider.setMovieAPIKey("unit-test-key")

        return (interactor, mockSearchService, mockStorageService)
    }

    private func createMockMovie(id: Int, title: String) -> Movie {
        Movie(
            id: id,
            title: title,
            overview: "Test overview",
            posterPath: "/test.jpg"
        )
    }

    @Test("Initial state has empty movies and no loading or error")
    func initialState() {
        // Given
        let (sut, _, _) = createTestComponents()
        defer {
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // When
        let initialState = sut.currentState

        // Then
        #expect(initialState.movies.isEmpty)
        #expect(initialState.favoriteMovies.isEmpty)
        #expect(!initialState.isLoading)
        #expect(initialState.error == nil)
        #expect(initialState.searchQuery == nil)
    }

    @Test("Search movies succeeds and updates state with query")
    func searchMoviesSuccess() async throws {
        // Given
        let (sut, mockSearchService, _) = createTestComponents()
        let query = "test query"
        defer {
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // When
        sut.handleAction(.searchMovies(query))

        // Wait for async operation and the mock response
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second for mock response

        // Then
        let finalState = sut.currentState
        #expect(finalState.searchQuery == query)
    }

    @Test("Search movies with empty query clears results")
    func searchMoviesWithEmptyQueryClearsResults() async throws {
        // Given
        let (sut, _, _) = createTestComponents()
        defer {
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // First perform a search to populate results
        sut.handleAction(.searchMovies("test"))
        try await Task.sleep(nanoseconds: 200_000_000)

        // When - Search with empty query
        sut.handleAction(.searchMovies(""))

        // Wait for state to update through the interactor
        try await Task.sleep(nanoseconds: 300_000_000)

        // Then - Results should be cleared
        let finalState = sut.currentState
        #expect(finalState.movies.isEmpty)
        #expect(!finalState.isLoading)
        #expect(finalState.error == nil)
        #expect(finalState.searchQuery == nil)
    }

    @Test("Toggle movie favorite adds movie to favorite movies")
    func toggleMovieLikeAddsToFavoriteMovies() async throws {
        // Given
        let (sut, _, storageService) = createTestComponents()
        let testMovie = createMockMovie(id: 1001, title: "Test Movie")
        defer {
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // When - Toggle favorite
        sut.handleAction(.toggleMovieFavorite(testMovie))

        // Wait for async operation
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then - Movie should be in favorite movies
        let likedMovies = try await storageService.fetchLikedMovies()
        #expect(likedMovies.contains(where: { $0.id == testMovie.id }))
    }

    @Test("Toggle movie favorite removes movie from favorite movies if already liked")
    func toggleMovieLikeRemovesFromFavoriteMovies() async throws {
        // Given
        let (sut, _, storageService) = createTestComponents()
        let testMovie = createMockMovie(id: 1002, title: "Test Movie 2")
        defer {
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // Toggle favorite to add
        sut.handleAction(.toggleMovieFavorite(testMovie))
        try await Task.sleep(nanoseconds: 200_000_000)

        // Verify movie is liked
        var likedMovies = try await storageService.fetchLikedMovies()
        #expect(likedMovies.contains(where: { $0.id == testMovie.id }))

        // When - Toggle favorite again to remove
        sut.handleAction(.toggleMovieFavorite(testMovie))
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then - Movie should be removed from favorite movies
        likedMovies = try await storageService.fetchLikedMovies()
        #expect(!likedMovies.contains(where: { $0.id == testMovie.id }))
    }

    @Test("Load persisted favorite movies updates state")
    func loadPersistedFavoriteMovies() async throws {
        // Given
        let (sut, _, storageService) = createTestComponents()
        let movie1 = createMockMovie(id: 1, title: "Movie 1")
        let movie2 = createMockMovie(id: 2, title: "Movie 2")
        defer {
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // First perform a search to get movies
        sut.handleAction(.searchMovies("test"))
        try await Task.sleep(nanoseconds: 200_000_000)

        // Save some movies as favorites directly to storage
        _ = try await storageService.toggleMovieFavorite(movie1)
        _ = try await storageService.toggleMovieFavorite(movie2)

        // When - Load persisted favorites
        sut.handleAction(.loadPersistedFavoriteMovies)
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then - Verify favorites were loaded
        let likedMovies = try await storageService.fetchLikedMovies()
        #expect(likedMovies.count == 2)
        #expect(likedMovies.contains(where: { $0.id == movie1.id }))
        #expect(likedMovies.contains(where: { $0.id == movie2.id }))
    }
}
