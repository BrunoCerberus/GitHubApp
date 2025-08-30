//
//  FavoritesMoviesViewModelTests.swift
//  GitHubAppTests
//

import Combine
@testable import GitHubApp
import Testing

struct FavoritesMoviesViewModelTests {
    private func createTestComponents() -> (FavoritesMoviesViewModel, MockFavoritesService) {
        // Reset storage cache for test isolation
        StorageServiceFactory.shared.resetCache()

        // Set up mock services
        let mockFavoritesService = MockFavoritesService()
        let serviceLocator = ServiceLocator()
        serviceLocator.register(FavoritesService.self, instance: mockFavoritesService)

        let mockDomainInteractor = FavoritesDomainInteractor(serviceLocator: serviceLocator)
        let viewModel = FavoritesMoviesViewModel(
            serviceLocator: serviceLocator,
            domainInteractor: mockDomainInteractor
        )

        return (viewModel, mockFavoritesService)
    }

    @Test("Toggle like adds and removes movie from favorites")
    func toggleLikeAddsAndRemovesMovie() async throws {
        // Given
        let (sut, mockFavoritesService) = createTestComponents()
        let movie = Movie(id: 1, title: "A", overview: "B", posterPath: nil)
        defer { StorageServiceFactory.shared.resetCache() }

        // Clear pre-populated mock data
        mockFavoritesService.setMockLikedMovies([])

        // Wait for initial state to load
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Then - Initially not favorited
        #expect(!sut.isFavorited(movie: movie))

        // When - Toggle favorite (add)
        sut.toggleFavorite(for: movie)

        // Wait for async operation to complete
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then - Should be favorited
        #expect(sut.isFavorited(movie: movie))

        // When - Toggle favorite again (remove)
        sut.toggleFavorite(for: movie)

        // Wait for second async operation to complete
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then - Should not be favorited
        #expect(!sut.isFavorited(movie: movie))
    }

    @Test("Favorites persist across different view model instances")
    func persistenceAcrossInstances() async throws {
        // Given
        let movie = Movie(id: 42, title: "Persist", overview: "Test", posterPath: nil)
        defer { StorageServiceFactory.shared.resetCache() }

        // Create first instance
        let (sut1, mockFavoritesService) = createTestComponents()

        // Clear pre-populated mock data
        mockFavoritesService.setMockLikedMovies([])

        // Wait for initial state to load
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // When - First instance adds favorite
        sut1.toggleFavorite(for: movie)

        // Wait for operation to complete
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then - First instance should show as favorited
        #expect(sut1.isFavorited(movie: movie))

        // When - Create second instance (using same mock service to ensure persistence)
        let serviceLocator = ServiceLocator()
        serviceLocator.register(FavoritesService.self, instance: mockFavoritesService)
        let mockDomainInteractor = FavoritesDomainInteractor(serviceLocator: serviceLocator)
        let sut2 = FavoritesMoviesViewModel(
            serviceLocator: serviceLocator,
            domainInteractor: mockDomainInteractor
        )

        // Wait for second instance to load state
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

        // Then - Second instance should also show as favorited (persistence test)
        #expect(sut2.isFavorited(movie: movie))
    }
}
