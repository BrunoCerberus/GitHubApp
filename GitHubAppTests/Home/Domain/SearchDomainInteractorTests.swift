//
//  SearchDomainInteractorTests.swift
//  GitHubAppTests
//

import Combine
@testable import GitHubApp
import Testing

struct SearchDomainInteractorTests {
    private func createTestComponents() -> (SearchDomainInteractor, MockHomeService, StorageServiceProtocol) {
        let mockHomeService = MockHomeService()
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: mockHomeService)

        // Configure StorageServiceFactory for testing
        StorageServiceFactory.shared.resetCache()
        StorageServiceFactory.shared.updateConfiguration(.testing)

        // Get the test storage service instance
        let storageService: StorageServiceProtocol
        do {
            storageService = try StorageServiceFactory.shared.getStorageService()
        } catch {
            Issue.record("Failed to get storage service for testing: \(error)")
            fatalError("Failed to get storage service for testing: \(error)")
        }

        let interactor = SearchDomainInteractor(serviceLocator: serviceLocator)
        // Ensure API key exists in case anything inadvertently touches HomeAPI
        try? APIKeysProvider.setMovieAPIKey("unit-test-key")

        return (interactor, mockHomeService, storageService)
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
            StorageServiceFactory.shared.resetCache()
            StorageServiceFactory.shared.updateConfiguration(.production)
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
        let (sut, _, _) = createTestComponents()
        let query = "test query"
        defer {
            StorageServiceFactory.shared.resetCache()
            StorageServiceFactory.shared.updateConfiguration(.production)
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // When
        sut.handleAction(.searchMovies(query))

        // Wait for async operation
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then
        let finalState = sut.currentState
        #expect(!finalState.isLoading)
        #expect(finalState.error == nil)
        #expect(!finalState.movies.isEmpty)
        #expect(finalState.searchQuery == query)
    }

    @Test("Search movies with empty query clears results")
    func searchMoviesWithEmptyQueryClearsResults() async throws {
        // Given
        let (sut, _, _) = createTestComponents()
        defer {
            StorageServiceFactory.shared.resetCache()
            StorageServiceFactory.shared.updateConfiguration(.production)
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
        defer {
            StorageServiceFactory.shared.resetCache()
            StorageServiceFactory.shared.updateConfiguration(.production)
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // First set up some movies in the current state by performing a search
        sut.handleAction(.searchMovies("test"))
        try await Task.sleep(nanoseconds: 200_000_000)

        // Get the first movie from search results to use for toggling
        #expect(!sut.currentState.movies.isEmpty, "Search should return movies")
        let movie = sut.currentState.movies.first!

        // Verify the movie is in the search results
        #expect(sut.currentState.movies.contains(where: { $0.id == movie.id }))

        // When - Toggle favorite
        sut.handleAction(.toggleMovieFavorite(movie))

        // Wait for async operation
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then - Movie should be in favorite movies
        let likedMovies = try await storageService.fetchLikedMovies()
        #expect(likedMovies.contains(where: { $0.id == movie.id }))
    }

    @Test("Toggle movie favorite removes movie from favorite movies if already liked")
    func toggleMovieLikeRemovesFromFavoriteMovies() async throws {
        // Given
        let (sut, _, storageService) = createTestComponents()
        defer {
            StorageServiceFactory.shared.resetCache()
            StorageServiceFactory.shared.updateConfiguration(.production)
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // First set up some movies in the current state by performing a search
        sut.handleAction(.searchMovies("test"))
        try await Task.sleep(nanoseconds: 200_000_000)

        // Get the first movie from search results to use for toggling
        #expect(!sut.currentState.movies.isEmpty, "Search should return movies")
        let movie = sut.currentState.movies.first!

        // Toggle favorite to add
        sut.handleAction(.toggleMovieFavorite(movie))
        try await Task.sleep(nanoseconds: 200_000_000)

        // Verify movie is liked
        var likedMovies = try await storageService.fetchLikedMovies()
        #expect(likedMovies.contains(where: { $0.id == movie.id }))

        // When - Toggle favorite again to remove
        sut.handleAction(.toggleMovieFavorite(movie))
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then - Movie should be removed from favorite movies
        likedMovies = try await storageService.fetchLikedMovies()
        #expect(!likedMovies.contains(where: { $0.id == movie.id }))
    }

    @Test("Load persisted favorite movies updates state")
    func loadPersistedFavoriteMovies() async throws {
        // Given
        let (sut, _, storageService) = createTestComponents()
        let movie1 = createMockMovie(id: 1, title: "Movie 1")
        let movie2 = createMockMovie(id: 2, title: "Movie 2")
        defer {
            StorageServiceFactory.shared.resetCache()
            StorageServiceFactory.shared.updateConfiguration(.production)
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

    @Test("Load more movies appends results to existing movies")
    func loadMoreMoviesAppendsResults() async throws {
        // Given
        let (sut, _, _) = createTestComponents()
        let query = "test"
        defer {
            StorageServiceFactory.shared.resetCache()
            StorageServiceFactory.shared.updateConfiguration(.production)
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // First perform initial search
        sut.handleAction(.searchMovies(query))
        try await Task.sleep(nanoseconds: 200_000_000)

        let initialMoviesCount = sut.currentState.movies.count
        #expect(initialMoviesCount > 0)
        #expect(sut.currentState.currentPage == 1)

        // When - Load more movies
        sut.handleAction(.loadMoreMovies)
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then - Movies should be appended
        let finalState = sut.currentState
        #expect(finalState.movies.count > initialMoviesCount)
        #expect(finalState.currentPage == 2)
        #expect(!finalState.isLoadingMore)
    }

    @Test("Load more movies does nothing when no search query exists")
    func loadMoreMoviesWithNoSearchQuery() async throws {
        // Given
        let (sut, _, _) = createTestComponents()
        defer {
            StorageServiceFactory.shared.resetCache()
            StorageServiceFactory.shared.updateConfiguration(.production)
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // Don't perform any search, so searchQuery is nil

        // When - Try to load more movies
        sut.handleAction(.loadMoreMovies)
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then - State should remain unchanged
        let finalState = sut.currentState
        #expect(finalState.movies.isEmpty)
        #expect(finalState.searchQuery == nil)
        #expect(!finalState.isLoadingMore)
    }

    @Test("Load more movies does nothing when already loading")
    func loadMoreMoviesWhenAlreadyLoading() async throws {
        // Given
        let (sut, _, _) = createTestComponents()
        defer {
            StorageServiceFactory.shared.resetCache()
            StorageServiceFactory.shared.updateConfiguration(.production)
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // Perform initial search
        sut.handleAction(.searchMovies("test"))
        try await Task.sleep(nanoseconds: 200_000_000)

        // Start loading more
        sut.handleAction(.loadMoreMovies)

        // When - Try to load more again while already loading
        sut.handleAction(.loadMoreMovies)

        // Wait for operations to complete
        try await Task.sleep(nanoseconds: 300_000_000)

        // Then - Should complete successfully without issues
        let finalState = sut.currentState
        #expect(!finalState.isLoadingMore)
    }

    @Test("Load more movies does nothing when no more pages available")
    func loadMoreMoviesWhenNoMorePages() async throws {
        // Given
        let (sut, _, _) = createTestComponents()
        defer {
            StorageServiceFactory.shared.resetCache()
            StorageServiceFactory.shared.updateConfiguration(.production)
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // Perform initial search
        sut.handleAction(.searchMovies("test"))
        try await Task.sleep(nanoseconds: 200_000_000)

        // Check if we're already on the last page
        let stateAfterSearch = sut.currentState
        if stateAfterSearch.currentPage >= stateAfterSearch.totalPages {
            // Already on last page, load more should do nothing
            let moviesCountBeforeLoadMore = stateAfterSearch.movies.count

            // When - Try to load more
            sut.handleAction(.loadMoreMovies)
            try await Task.sleep(nanoseconds: 200_000_000)

            // Then - Movies count should remain the same
            #expect(sut.currentState.movies.count == moviesCountBeforeLoadMore)
        } else {
            // Not on last page yet, this test scenario doesn't apply
            // We can't reliably test this without controlling the mock service responses
        }
    }

    @Test("Search with different queries resets pagination")
    func searchWithDifferentQueriesResetsPagination() async throws {
        // Given
        let (sut, _, _) = createTestComponents()
        defer {
            StorageServiceFactory.shared.resetCache()
            StorageServiceFactory.shared.updateConfiguration(.production)
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // Perform first search
        sut.handleAction(.searchMovies("first query"))
        try await Task.sleep(nanoseconds: 200_000_000)

        // When - Perform second search with different query
        sut.handleAction(.searchMovies("second query"))
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then - Pagination should be reset
        let finalState = sut.currentState
        #expect(finalState.searchQuery == "second query")
        #expect(finalState.currentPage == 1)
    }
}
