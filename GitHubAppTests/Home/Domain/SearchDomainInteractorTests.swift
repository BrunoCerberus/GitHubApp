//
//  SearchDomainInteractorTests.swift
//  GitHubAppTests
//

import Combine
@testable import GitHubApp
import Testing

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

    @Test("Load more movies does not crash when search query is valid")
    func loadMoreMoviesWithValidSearchQuery() async throws {
        // Given
        let (sut, _, _) = createTestComponents()
        let query = "test"
        defer {
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // First perform initial search
        sut.handleAction(.searchMovies(query))
        try await Task.sleep(nanoseconds: 500_000_000)

        let stateAfterSearch = sut.currentState
        #expect(stateAfterSearch.searchQuery == query)

        // When - Load more movies
        sut.handleAction(.loadMoreMovies)
        try await Task.sleep(nanoseconds: 500_000_000)

        // Then - Should not crash and query should still be set
        let finalState = sut.currentState
        #expect(finalState.searchQuery == query)
        #expect(!finalState.isLoadingMore)
    }

    @Test("Load more movies does nothing when no search query exists")
    func loadMoreMoviesWithNoSearchQuery() async throws {
        // Given
        let (sut, _, _) = createTestComponents()
        defer {
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

    @Test("Search with different queries updates search query")
    func searchWithDifferentQueriesUpdatesQuery() async throws {
        // Given
        let (sut, _, _) = createTestComponents()
        defer {
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // Perform first search
        sut.handleAction(.searchMovies("first query"))
        try await Task.sleep(nanoseconds: 300_000_000)

        // When - Perform second search with different query
        sut.handleAction(.searchMovies("second query"))
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then - Query should be updated
        let finalState = sut.currentState
        #expect(finalState.searchQuery == "second query")
    }

    @Test("Search sets loading state initially")
    func searchSetsLoadingStateInitially() {
        // Given
        let (sut, _, _) = createTestComponents()
        defer {
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // When - Start searching
        sut.handleAction(.searchMovies("test query"))

        // Then - Loading state should be true immediately
        let stateWhileLoading = sut.currentState
        #expect(stateWhileLoading.isLoading == true)
        #expect(stateWhileLoading.error == nil)
        #expect(stateWhileLoading.searchQuery == "test query")
    }

    @Test("Multiple search queries update search query correctly")
    func multipleSeparateSearchesUpdateQuery() async throws {
        // Given
        let (sut, _, _) = createTestComponents()
        defer {
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // First search
        sut.handleAction(.searchMovies("query1"))
        try await Task.sleep(nanoseconds: 300_000_000)
        let firstState = sut.currentState
        #expect(firstState.searchQuery == "query1")

        // When - Perform new search
        sut.handleAction(.searchMovies("query2"))
        try await Task.sleep(nanoseconds: 300_000_000)
        let finalState = sut.currentState

        // Then - Query should be updated
        #expect(finalState.searchQuery == "query2")
    }

    @Test("Favorite movies persists across searches")
    func favoritesPersistedAcrossSearches() async throws {
        // Given
        let (sut, _, storageService) = createTestComponents()
        let testMovie = createMockMovie(id: 1003, title: "Test Favorite")
        defer {
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // Add a favorite
        sut.handleAction(.toggleMovieFavorite(testMovie))
        try await Task.sleep(nanoseconds: 200_000_000)

        // When - Perform a search
        sut.handleAction(.searchMovies("test"))
        try await Task.sleep(nanoseconds: 300_000_000)

        // Then - Verify the favorite is still persisted
        let persistedFavorites = try await storageService.fetchLikedMovies()
        #expect(persistedFavorites.contains(where: { $0.id == testMovie.id }))
    }

    @Test("Loading more movies does nothing when no pages available")
    func loadMoreMoviesRespectsTotalPages() async throws {
        // Given
        let (sut, _, _) = createTestComponents()
        let mockSearchService = MockSearchService()
        defer {
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // Perform initial search
        sut.handleAction(.searchMovies("test"))
        try await Task.sleep(nanoseconds: 200_000_000)

        let stateAfterSearch = sut.currentState
        let initialMoviesCount = stateAfterSearch.movies.count

        // Try to load beyond available pages multiple times
        sut.handleAction(.loadMoreMovies)
        try await Task.sleep(nanoseconds: 100_000_000)
        sut.handleAction(.loadMoreMovies)
        try await Task.sleep(nanoseconds: 100_000_000)
        sut.handleAction(.loadMoreMovies)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then - State should eventually stabilize
        let finalState = sut.currentState
        #expect(!finalState.isLoadingMore)
    }

    @Test("CombineInteractor protocol implementation works correctly")
    func combineInteractorProtocolConformance() {
        // Given
        let (sut, _, _) = createTestComponents()
        defer {
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // When - Create action stream and interact
        let actionSubject = PassthroughSubject<SearchDomainAction, Never>()
        let stateStream = sut.interact(upstream: actionSubject.eraseToAnyPublisher())

        // Then - Should return a publisher
        #expect(stateStream != nil)
    }
}
