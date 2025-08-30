//
//  HomeDomainInteractorTests.swift
//  GitHubAppTests
//

import Combine
@testable import GitHubApp
import Testing

struct HomeDomainInteractorTests {
    private func createTestComponents() -> (HomeDomainInteractor, MockHomeService, StorageServiceProtocol) {
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

        let interactor = HomeDomainInteractor(serviceLocator: serviceLocator)
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

    @Test("Fetch upcoming movies succeeds and updates state")
    func fetchUpcomingMoviesSuccess() async throws {
        // Given
        let (sut, _, _) = createTestComponents()
        defer {
            StorageServiceFactory.shared.resetCache()
            StorageServiceFactory.shared.updateConfiguration(.production)
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // When
        sut.handleAction(.fetchUpcomingMovies)

        // Wait for async operations
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then - Check final state
        let finalState = sut.currentState
        #expect(!finalState.isLoading)
        #expect(finalState.error == nil)
        #expect(!finalState.movies.isEmpty)
        #expect(finalState.searchQuery == nil)
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

    @Test("Search movies with empty query fetches upcoming movies")
    func searchMoviesWithEmptyQueryFetchesUpcoming() async throws {
        // Given
        let (sut, _, _) = createTestComponents()
        defer {
            StorageServiceFactory.shared.resetCache()
            StorageServiceFactory.shared.updateConfiguration(.production)
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // When
        sut.handleAction(.searchMovies(""))

        // Wait for async operation
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then
        let finalState = sut.currentState
        #expect(!finalState.isLoading)
        #expect(finalState.error == nil)
        #expect(!finalState.movies.isEmpty)
        #expect(finalState.searchQuery == nil) // Should be nil when fetching upcoming
    }

    @Test("Toggle movie like adds movie to favorite movies")
    func toggleMovieLikeAddsToLikedMovies() async throws {
        // Given
        let (sut, _, storageService) = createTestComponents()
        let movie = createMockMovie(id: 1, title: "Test Movie")
        defer {
            StorageServiceFactory.shared.resetCache()
            StorageServiceFactory.shared.updateConfiguration(.production)
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // First set up some movies in the current state
        sut.handleAction(.fetchUpcomingMovies)
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // When - toggle like
        sut.handleAction(.toggleMovieFavorite(movie))
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then - Check if movie is in storage service
        let favoriteMovies = try await storageService.fetchLikedMovies()
        #expect(favoriteMovies.contains { $0.id == movie.id })
    }

    @Test("Toggle movie like removes movie from favorite movies")
    func toggleMovieLikeRemovesFromLikedMovies() async throws {
        // Given
        let (sut, _, storageService) = createTestComponents()
        let movie = createMockMovie(id: 1, title: "Test Movie")
        defer {
            StorageServiceFactory.shared.resetCache()
            StorageServiceFactory.shared.updateConfiguration(.production)
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // First add the movie to test storage
        try await storageService.save([movie], context: StorageContext.favoriteMovies)

        // When - toggle to remove
        await MainActor.run {
            sut.handleAction(.toggleMovieFavorite(movie))
        }

        // Wait for async operation
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then - Check if movie is removed from storage
        let favoriteMovies = try await storageService.fetchLikedMovies()
        #expect(!favoriteMovies.contains { $0.id == movie.id })
    }

    @Test("Load persisted favorite movies updates state correctly")
    func loadPersistedLikedMovies() async throws {
        // Given - Use the same movie IDs that MockHomeService returns (346698, 615656, 496450)
        let (sut, _, storageService) = createTestComponents()
        let movie1 = createMockMovie(id: 346_698, title: "Barbie") // This matches MockHomeService
        let movie2 = createMockMovie(id: 615_656, title: "Meg 2") // This matches MockHomeService
        let favoriteMovies = [movie1, movie2]
        defer {
            StorageServiceFactory.shared.resetCache()
            StorageServiceFactory.shared.updateConfiguration(.production)
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // Setup test storage with favorite movies
        try await storageService.save(favoriteMovies, context: StorageContext.favoriteMovies)

        // First load some movies from MockHomeService
        await MainActor.run {
            sut.handleAction(.fetchUpcomingMovies)
        }

        // Wait for fetch to complete
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // When - load persisted favorite movies
        await MainActor.run {
            sut.handleAction(.loadPersistedFavoriteMovies)
        }

        // Wait for load to complete
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then
        await MainActor.run {
            let finalState = sut.currentState
            // Should contain both movies since they're both in current movies and persisted favorite movies
            #expect(finalState.favoriteMovies.contains { $0.id == movie1.id })
            #expect(finalState.favoriteMovies.contains { $0.id == movie2.id })
        }
    }

    @Test("Fetch movies with service error updates state with error")
    func fetchMoviesWithServiceError() async throws {
        // Given
        let (sut, mockHomeService, _) = createTestComponents()
        mockHomeService.shouldFail = true
        defer {
            StorageServiceFactory.shared.resetCache()
            StorageServiceFactory.shared.updateConfiguration(.production)
            try? APIKeysProvider.removeMovieAPIKey()
        }

        // When
        sut.handleAction(.fetchUpcomingMovies)

        // Wait for async operation
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then
        let finalState = sut.currentState
        #expect(!finalState.isLoading)
        #expect(finalState.error != nil)
        #expect(finalState.movies.isEmpty)
    }
}
