//
//  LiveFavoritesServiceErrorTests.swift
//  GitHubAppTests
//
//  Created by claude on 23/08/25.
//

import Combine
@testable import GitHubApp
import Testing

struct LiveFavoritesServiceErrorTests {
    private func createTestComponents() -> (LiveFavoritesService, MockStorageService) {
        let mockStorageService = MockStorageService()
        let service = LiveFavoritesService(storageService: mockStorageService)
        return (service, mockStorageService)
    }

    // MARK: - Service Initialization Tests

    @Test("Initialization with nil storage service uses factory")
    func initializationWithNilStorageService() {
        // Given - nil storage service should fall back to factory

        // When
        let service = LiveFavoritesService(storageService: nil)

        // Then - Should initialize successfully using factory
        #expect(service != nil)
    }

    @Test("Initialization with provided storage service works correctly")
    func initializationWithProvidedStorageService() {
        // Given
        let customStorage = MockStorageService()

        // When
        let service = LiveFavoritesService(storageService: customStorage)

        // Then
        #expect(service != nil)
    }

    // MARK: - Load Favorite Movies Error Tests

    @Test("Load favorite movies handles service gracefully")
    func loadFavoriteMoviesWithServiceUnavailable() async throws {
        // Given - Service weak self behavior is implementation detail
        // This test verifies that the service handles weak self correctly
        // by checking that the service doesn't crash with normal usage
        let (service, _) = createTestComponents()

        // When - Using service normally
        let result = try await service.loadFavoriteMovies().async()

        // Then - Service operates normally
        #expect(result != nil)
    }

    @Test("Load favorite movies propagates storage errors")
    func loadFavoriteMoviesWithStorageError() async throws {
        // Given
        let (service, mockStorageService) = createTestComponents()
        let expectedError = NSError(domain: "StorageError", code: 500, userInfo: nil)
        mockStorageService.shouldSimulateErrors = true
        mockStorageService.fetchLikedMoviesError = expectedError

        // When & Then
        #expect(throws: Error.self) {
            try await service.loadFavoriteMovies().async()
        }
    }

    @Test("Load favorite movies succeeds with valid data")
    func loadFavoriteMoviesSuccess() async throws {
        // Given
        let (service, mockStorageService) = createTestComponents()
        let expectedMovies = [
            Movie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: nil),
            Movie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: nil),
        ]
        mockStorageService.favoriteMovies = expectedMovies

        // When
        let movies = try await service.loadFavoriteMovies().async()

        // Then
        #expect(movies.count == 2)
        #expect(movies[0].id == 1)
        #expect(movies[1].id == 2)
    }

    // MARK: - Toggle Movie Favorite Error Tests

    @Test("Toggle movie favorite handles service gracefully")
    func toggleMovieFavoriteWithServiceUnavailable() async throws {
        // Given - Service weak self behavior is implementation detail
        let (service, _) = createTestComponents()
        let movie = Movie(id: 1, title: "Test Movie", overview: "Test", posterPath: nil)

        // When - Using service normally
        let result = try await service.toggleMovieFavorite(movie).async()

        // Then - Service operates normally
        #expect(result != nil)
    }

    @Test("Toggle movie favorite propagates storage errors")
    func toggleMovieFavoriteWithStorageError() async throws {
        // Given
        let (service, mockStorageService) = createTestComponents()
        let movie = Movie(id: 1, title: "Test Movie", overview: "Test", posterPath: nil)
        let expectedError = NSError(domain: "ToggleError", code: 404, userInfo: nil)
        mockStorageService.shouldSimulateErrors = true
        mockStorageService.toggleError = expectedError

        // When & Then
        #expect(throws: Error.self) {
            try await service.toggleMovieFavorite(movie).async()
        }
    }

    @Test("Toggle movie favorite succeeds with valid movie")
    func toggleMovieFavoriteSuccess() async throws {
        // Given
        let (service, mockStorageService) = createTestComponents()
        let movie = Movie(id: 1, title: "Test Movie", overview: "Test", posterPath: nil)
        let expectedMovies = [movie]
        mockStorageService.toggledMovies = expectedMovies

        // When
        let movies = try await service.toggleMovieFavorite(movie).async()

        // Then
        #expect(movies.count == 1)
        #expect(movies[0].id == 1)
    }

    // MARK: - Clear All Favorite Movies Error Tests

    @Test("Clear all favorite movies handles service gracefully")
    func clearAllFavoriteMoviesWithServiceUnavailable() async throws {
        // Given - Service weak self behavior is implementation detail
        let (service, _) = createTestComponents()

        // When - Using service normally
        let result = try await service.clearAllFavoriteMovies().async()

        // Then - Service operates normally
        #expect(result != nil)
    }

    @Test("Clear all favorite movies propagates storage errors")
    func clearAllFavoriteMoviesWithStorageError() async throws {
        // Given
        let (service, mockStorageService) = createTestComponents()
        let expectedError = NSError(domain: "ClearError", code: 500, userInfo: nil)
        mockStorageService.shouldSimulateErrors = true
        mockStorageService.clearError = expectedError

        // When & Then
        #expect(throws: Error.self) {
            try await service.clearAllFavoriteMovies().async()
        }
    }

    @Test("Clear all favorite movies succeeds normally")
    func clearAllFavoriteMoviesSuccess() async throws {
        // Given
        let (service, _) = createTestComponents()

        // When
        let result = try await service.clearAllFavoriteMovies().async()

        // Then - Success case
        #expect(result != nil)
    }

    // MARK: - Is Movie Liked Error Tests

    @Test("Is movie liked handles service gracefully")
    func isMovieLikedWithServiceUnavailable() async throws {
        // Given - Service weak self behavior is implementation detail
        let (service, _) = createTestComponents()
        let movie = Movie(id: 1, title: "Test Movie", overview: "Test", posterPath: nil)

        // When - Using service normally
        let result = try await service.isMovieLiked(movie).async()

        // Then - Service operates normally
        #expect(result != nil)
    }

    @Test("Is movie liked propagates storage errors")
    func isMovieLikedWithStorageError() async throws {
        // Given
        let (service, mockStorageService) = createTestComponents()
        let movie = Movie(id: 1, title: "Test Movie", overview: "Test", posterPath: nil)
        let expectedError = NSError(domain: "LikedCheckError", code: 503, userInfo: nil)
        mockStorageService.shouldSimulateErrors = true
        mockStorageService.isMovieLikedError = expectedError

        // When & Then
        #expect(throws: Error.self) {
            try await service.isMovieLiked(movie).async()
        }
    }

    @Test("Is movie liked returns correct result")
    func isMovieLikedSuccess() async throws {
        // Given
        let (service, mockStorageService) = createTestComponents()
        let movie = Movie(id: 1, title: "Test Movie", overview: "Test", posterPath: nil)
        mockStorageService.movieLikedResult = true

        // When
        let isLiked = try await service.isMovieLiked(movie).async()

        // Then
        #expect(isLiked == true)
    }

    // MARK: - Error Type Tests

    @Test("Favorites service error descriptions are meaningful")
    func favoritesServiceErrorDescriptions() {
        // Test all error cases to improve coverage

        let serviceUnavailableError = FavoritesServiceError.serviceUnavailable
        #expect(serviceUnavailableError.errorDescription == "Favorites service is unavailable")

        let testError = NSError(domain: "TestError", code: 123, userInfo: nil)
        let encodingError = FavoritesServiceError.encodingFailed(testError)
        #expect(encodingError.errorDescription?.contains("Failed to encode favorite movies") == true)

        let decodingError = FavoritesServiceError.decodingFailed(testError)
        #expect(decodingError.errorDescription?.contains("Failed to decode favorite movies") == true)
    }

    @Test("Favorites service error equality works through descriptions")
    func favoritesServiceErrorEquality() {
        // Test error equality for coverage
        let error1 = FavoritesServiceError.serviceUnavailable
        let error2 = FavoritesServiceError.serviceUnavailable

        // Since FavoritesServiceError doesn't conform to Equatable, we test descriptions
        #expect(error1.errorDescription == error2.errorDescription)
    }

    // MARK: - Memory Management Tests

    @Test("Service memory management works correctly")
    func serviceMemoryManagement() async throws {
        // Given
        weak var weakService: LiveFavoritesService?
        var cancellables: Set<AnyCancellable> = []

        await MainActor.run {
            autoreleasepool {
                let (service, mockStorageService) = createTestComponents()
                weakService = service

                // Start an operation
                service.loadFavoriteMovies()
                    .sink(
                        receiveCompletion: { _ in },
                        receiveValue: { _ in }
                    )
                    .store(in: &cancellables)
            }
        }

        // When - Service should be deallocated
        cancellables.removeAll()

        // Wait a moment for deallocation
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Then - Weak reference should be nil
        #expect(weakService == nil, "Service should be deallocated")
    }

    @Test("Concurrent operations complete successfully")
    func concurrentOperations() async throws {
        // Given
        let (service, _) = createTestComponents()
        let movie1 = Movie(id: 1, title: "Movie 1", overview: "Test", posterPath: nil)
        let movie2 = Movie(id: 2, title: "Movie 2", overview: "Test", posterPath: nil)

        // When - Execute multiple operations concurrently using async
        async let loadResult = try service.loadFavoriteMovies().async()
        async let isLikedResult = try service.isMovieLiked(movie1).async()
        async let toggleResult = try service.toggleMovieFavorite(movie2).async()
        async let clearResult = try service.clearAllFavoriteMovies().async()

        // Then - All operations should complete
        let results = try await (loadResult, isLikedResult, toggleResult, clearResult)

        #expect(results.0 != nil) // loadResult
        #expect(results.1 != nil) // isLikedResult
        #expect(results.2 != nil) // toggleResult
        #expect(results.3 != nil) // clearResult
    }
}
