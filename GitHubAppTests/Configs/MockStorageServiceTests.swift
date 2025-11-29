//
//  MockStorageServiceTests.swift
//  GitHubAppTests
//
//  Created by Claude Code
//

import Foundation
@testable import GitHubApp
import Testing

/**
 * Comprehensive unit tests for MockStorageService covering all methods and error paths.
 *
 * Tests cover:
 * - Generic CRUD operations (save, fetch, delete)
 * - Movie-specific operations (like, toggle, fetch liked)
 * - Error simulation
 * - State management
 */
@MainActor
struct MockStorageServiceTests {
    @Test("Save single movie adds movie to storage")
    func saveSingleMovieAddsToStorage() async throws {
        // Given
        let service = MockStorageService()
        let movie = Movie(id: 1, title: "Test Movie", overview: "Test", posterPath: nil)

        // When
        try await service.save(movie, context: nil)

        // Then
        let movies: [Movie] = try await service.fetch(Movie.self, context: nil)
        #expect(movies.count == 1, "Should have one movie")
        #expect(movies.first?.id == 1, "Should be the test movie")
    }

    @Test("Save multiple movies adds all to storage")
    func saveMultipleMoviesAddsAllToStorage() async throws {
        // Given
        let service = MockStorageService()
        let movies = [
            Movie(id: 1, title: "Movie 1", overview: "Test", posterPath: nil),
            Movie(id: 2, title: "Movie 2", overview: "Test", posterPath: nil),
            Movie(id: 3, title: "Movie 3", overview: "Test", posterPath: nil),
        ]

        // When
        try await service.save(movies, context: nil)

        // Then
        let fetchedMovies: [Movie] = try await service.fetch(Movie.self, context: nil)
        #expect(fetchedMovies.count == 3, "Should have three movies")
    }

    @Test("Save replaces existing movie with same ID")
    func saveReplacesExistingMovieWithSameID() async throws {
        // Given
        let service = MockStorageService()
        let movie1 = Movie(id: 1, title: "Original", overview: "Test", posterPath: nil)
        let movie2 = Movie(id: 1, title: "Updated", overview: "Test", posterPath: nil)

        // When
        try await service.save(movie1, context: nil)
        try await service.save(movie2, context: nil)

        // Then
        let movies: [Movie] = try await service.fetch(Movie.self, context: nil)
        #expect(movies.count == 1, "Should have only one movie")
        #expect(movies.first?.title == "Updated", "Should be the updated movie")
    }

    @Test("Fetch by ID returns correct movie")
    func fetchByIDReturnsCorrectMovie() async throws {
        // Given
        let service = MockStorageService()
        let movies = [
            Movie(id: 1, title: "Movie 1", overview: "Test", posterPath: nil),
            Movie(id: 2, title: "Movie 2", overview: "Test", posterPath: nil),
            Movie(id: 3, title: "Movie 3", overview: "Test", posterPath: nil),
        ]
        try await service.save(movies, context: nil)

        // When
        let movie: Movie? = try await service.fetch(Movie.self, id: 2, context: nil)

        // Then
        #expect(movie != nil, "Should find movie")
        #expect(movie?.id == 2, "Should be movie with ID 2")
        #expect(movie?.title == "Movie 2", "Should have correct title")
    }

    @Test("Fetch by non-existent ID returns nil")
    func fetchByNonExistentIDReturnsNil() async throws {
        // Given
        let service = MockStorageService()

        // When
        let movie: Movie? = try await service.fetch(Movie.self, id: 999, context: nil)

        // Then
        #expect(movie == nil, "Should not find movie")
    }

    @Test("Delete single movie removes from storage")
    func deleteSingleMovieRemovesFromStorage() async throws {
        // Given
        let service = MockStorageService()
        let movie = Movie(id: 1, title: "Test Movie", overview: "Test", posterPath: nil)
        try await service.save(movie, context: nil)

        // When
        try await service.delete(movie, context: nil)

        // Then
        let movies: [Movie] = try await service.fetch(Movie.self, context: nil)
        #expect(movies.isEmpty, "Should have no movies")
    }

    @Test("Delete multiple movies removes all from storage")
    func deleteMultipleMoviesRemovesAllFromStorage() async throws {
        // Given
        let service = MockStorageService()
        let movies = [
            Movie(id: 1, title: "Movie 1", overview: "Test", posterPath: nil),
            Movie(id: 2, title: "Movie 2", overview: "Test", posterPath: nil),
            Movie(id: 3, title: "Movie 3", overview: "Test", posterPath: nil),
        ]
        try await service.save(movies, context: nil)

        // When
        try await service.delete([movies[0], movies[2]], context: nil)

        // Then
        let remaining: [Movie] = try await service.fetch(Movie.self, context: nil)
        #expect(remaining.count == 1, "Should have one movie remaining")
        #expect(remaining.first?.id == 2, "Should be movie 2")
    }

    @Test("Delete all movies clears storage")
    func deleteAllMoviesClearsStorage() async throws {
        // Given
        let service = MockStorageService()
        let movies = [
            Movie(id: 1, title: "Movie 1", overview: "Test", posterPath: nil),
            Movie(id: 2, title: "Movie 2", overview: "Test", posterPath: nil),
        ]
        try await service.save(movies, context: nil)

        // When
        try await service.deleteAll(Movie.self, context: nil)

        // Then
        let remaining: [Movie] = try await service.fetch(Movie.self, context: nil)
        #expect(remaining.isEmpty, "Should have no movies")
    }

    @Test("Is movie liked returns true for liked movie")
    func isMovieLikedReturnsTrueForLikedMovie() async throws {
        // Given
        let service = MockStorageService()
        let movie = Movie(id: 1, title: "Test Movie", overview: "Test", posterPath: nil)
        try await service.save(movie, context: StorageContext.favoriteMovies)

        // When
        let isLiked = try await service.isMovieLiked(movie)

        // Then
        #expect(isLiked, "Movie should be liked")
    }

    @Test("Is movie liked returns false for non-liked movie")
    func isMovieLikedReturnsFalseForNonLikedMovie() async throws {
        // Given
        let service = MockStorageService()
        let movie = Movie(id: 1, title: "Test Movie", overview: "Test", posterPath: nil)

        // When
        let isLiked = try await service.isMovieLiked(movie)

        // Then
        #expect(!isLiked, "Movie should not be liked")
    }

    @Test("Toggle movie favorite adds movie when not liked")
    func toggleMovieFavoriteAddsMovieWhenNotLiked() async throws {
        // Given
        let service = MockStorageService()
        let movie = Movie(id: 1, title: "Test Movie", overview: "Test", posterPath: nil)

        // When
        let result = try await service.toggleMovieFavorite(movie)

        // Then
        #expect(result.count == 1, "Should have one favorite")
        #expect(result.first?.id == 1, "Should be the test movie")
        let isLiked = try await service.isMovieLiked(movie)
        #expect(isLiked, "Movie should now be liked")
    }

    @Test("Toggle movie favorite removes movie when already liked")
    func toggleMovieFavoriteRemovesMovieWhenAlreadyLiked() async throws {
        // Given
        let service = MockStorageService()
        let movie = Movie(id: 1, title: "Test Movie", overview: "Test", posterPath: nil)
        try await service.save(movie, context: StorageContext.favoriteMovies)

        // When
        let result = try await service.toggleMovieFavorite(movie)

        // Then
        #expect(result.isEmpty, "Should have no favorites")
        let isLiked = try await service.isMovieLiked(movie)
        #expect(!isLiked, "Movie should not be liked")
    }

    @Test("Fetch liked movies returns all favorites")
    func fetchLikedMoviesReturnsAllFavorites() async throws {
        // Given
        let service = MockStorageService()
        let movies = [
            Movie(id: 1, title: "Movie 1", overview: "Test", posterPath: nil),
            Movie(id: 2, title: "Movie 2", overview: "Test", posterPath: nil),
        ]
        try await service.save(movies, context: StorageContext.favoriteMovies)

        // When
        let favorites = try await service.fetchLikedMovies()

        // Then
        #expect(favorites.count == 2, "Should have two favorites")
    }

    @Test("Clear favorite movies removes all favorites")
    func clearFavoriteMoviesRemovesAllFavorites() async throws {
        // Given
        let service = MockStorageService()
        let movies = [
            Movie(id: 1, title: "Movie 1", overview: "Test", posterPath: nil),
            Movie(id: 2, title: "Movie 2", overview: "Test", posterPath: nil),
        ]
        try await service.save(movies, context: StorageContext.favoriteMovies)

        // When
        try await service.clearFavoriteMovies()

        // Then
        let favorites = try await service.fetchLikedMovies()
        #expect(favorites.isEmpty, "Should have no favorites")
    }

    // MARK: - Error Simulation Tests

    @Test("Is movie liked throws error when error simulation enabled")
    func isMovieLikedThrowsErrorWhenErrorSimulationEnabled() async throws {
        // Given
        let service = MockStorageService()
        service.shouldSimulateErrors = true
        let userInfo = [NSLocalizedDescriptionKey: "Simulated error"]
        service.isMovieLikedError = NSError(domain: "test", code: 1, userInfo: userInfo)
        let movie = Movie(id: 1, title: "Test Movie", overview: "Test", posterPath: nil)

        // When/Then
        do {
            _ = try await service.isMovieLiked(movie)
            #expect(Bool(false), "Should throw error")
        } catch {
            #expect(true, "Should throw error")
        }
    }

    @Test("Toggle favorite throws error when error simulation enabled")
    func toggleFavoriteThrowsErrorWhenErrorSimulationEnabled() async throws {
        // Given
        let service = MockStorageService()
        service.shouldSimulateErrors = true
        service.toggleError = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Toggle error"])
        let movie = Movie(id: 1, title: "Test Movie", overview: "Test", posterPath: nil)

        // When/Then
        do {
            _ = try await service.toggleMovieFavorite(movie)
            #expect(Bool(false), "Should throw error")
        } catch {
            #expect(true, "Should throw error")
        }
    }

    @Test("Clear favorites throws error when error simulation enabled")
    func clearFavoritesThrowsErrorWhenErrorSimulationEnabled() async throws {
        // Given
        let service = MockStorageService()
        service.shouldSimulateErrors = true
        service.clearError = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Clear error"])

        // When/Then
        do {
            try await service.clearFavoriteMovies()
            #expect(Bool(false), "Should throw error")
        } catch {
            #expect(true, "Should throw error")
        }
    }

    @Test("Fetch liked movies throws error when error simulation enabled")
    func fetchLikedMoviesThrowsErrorWhenErrorSimulationEnabled() async throws {
        // Given
        let service = MockStorageService()
        service.shouldSimulateErrors = true
        let userInfo = [NSLocalizedDescriptionKey: "Fetch error"]
        service.fetchLikedMoviesError = NSError(domain: "test", code: 1, userInfo: userInfo)

        // When/Then
        do {
            _ = try await service.fetchLikedMovies()
            #expect(Bool(false), "Should throw error")
        } catch {
            #expect(true, "Should throw error")
        }
    }

    // MARK: - Custom Result Tests

    @Test("Toggle favorite uses custom toggled movies when set")
    func toggleFavoriteUsesCustomToggledMovies() async throws {
        // Given
        let service = MockStorageService()
        let customMovies = [
            Movie(id: 99, title: "Custom Movie", overview: "Test", posterPath: nil),
        ]
        service.toggledMovies = customMovies
        let movie = Movie(id: 1, title: "Test Movie", overview: "Test", posterPath: nil)

        // When
        let result = try await service.toggleMovieFavorite(movie)

        // Then
        #expect(result.count == 1, "Should return custom movies")
        #expect(result.first?.id == 99, "Should be custom movie")
    }

    @Test("Favorite movies property allows pre-setting favorites")
    func favoriteMoviesPropertyAllowsPreSettingFavorites() async throws {
        // Given
        let service = MockStorageService()
        let presetMovies = [
            Movie(id: 10, title: "Preset 1", overview: "Test", posterPath: nil),
            Movie(id: 20, title: "Preset 2", overview: "Test", posterPath: nil),
        ]
        service.favoriteMovies = presetMovies

        // When
        let favorites = service.favoriteMovies

        // Then
        #expect(favorites.count == 2, "Should have preset favorites")
        #expect(favorites.first?.id == 10, "Should be first preset movie")
    }

    @Test("Movie liked result property overrides actual check")
    func movieLikedResultOverridesActualCheck() async throws {
        // Given
        let service = MockStorageService()
        service.movieLikedResult = true
        let movie = Movie(id: 1, title: "Test Movie", overview: "Test", posterPath: nil)
        // Don't save the movie, but movieLikedResult is true

        // When
        let isLiked = try await service.isMovieLiked(movie)

        // Then
        #expect(isLiked, "Should return true from movieLikedResult override")
    }
}
