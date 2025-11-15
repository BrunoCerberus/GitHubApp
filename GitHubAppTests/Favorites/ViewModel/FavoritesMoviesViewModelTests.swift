//
//  FavoritesMoviesViewModelTests.swift
//  GitHubAppTests
//

import Combine
@testable import GitHubApp
import Testing

@MainActor
struct FavoritesMoviesViewModelTests {
    private func createTestComponents() -> (FavoritesMoviesViewModel, MockFavoritesService) {
        // Set up mock services
        let mockFavoritesService = MockFavoritesService()
        let mockStorageService = MockStorageService()

        let serviceLocator = ServiceLocator()
        serviceLocator.register(FavoritesService.self, instance: mockFavoritesService)
        serviceLocator.register(StorageService.self, instance: mockStorageService)

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

        // Create first instance with shared storage
        let mockFavoritesService = MockFavoritesService()
        let mockStorageService = MockStorageService()

        let serviceLocator1 = ServiceLocator()
        serviceLocator1.register(FavoritesService.self, instance: mockFavoritesService)
        serviceLocator1.register(StorageService.self, instance: mockStorageService)

        let mockDomainInteractor1 = FavoritesDomainInteractor(serviceLocator: serviceLocator1)
        let sut1 = FavoritesMoviesViewModel(
            serviceLocator: serviceLocator1,
            domainInteractor: mockDomainInteractor1
        )

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

        // When - Create second instance (using SAME mock services to ensure persistence)
        let serviceLocator2 = ServiceLocator()
        serviceLocator2.register(FavoritesService.self, instance: mockFavoritesService)
        serviceLocator2.register(StorageService.self, instance: mockStorageService)
        let mockDomainInteractor2 = FavoritesDomainInteractor(serviceLocator: serviceLocator2)
        let sut2 = FavoritesMoviesViewModel(
            serviceLocator: serviceLocator2,
            domainInteractor: mockDomainInteractor2
        )

        // Load favorites on second instance to ensure it reads the persisted state
        await MainActor.run {
            sut2.loadFavoriteMovies()
        }

        // Wait for second instance to load state
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds for loading

        // Then - Second instance should also show as favorited (persistence test)
        await MainActor.run {
            #expect(sut2.isFavorited(movie: movie), "Second instance should show persisted favorite")
        }
    }
}
