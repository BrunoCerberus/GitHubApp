//
//  FavoritesServiceTests.swift
//  GitHubAppTests
//
//  Created by bruno on feature/liked-clean-architecture.
//

import Combine
@testable import GitHubApp
import Testing

struct FavoritesServiceTests {
    @Test("Loading favorite movies returns empty list when no movies are saved")
    func loadLikedMoviesEmpty() async throws {
        // Given
        let mockFavoritesService = MockFavoritesService()
        let sut: FavoritesService = mockFavoritesService

        // Clear pre-populated mock data
        mockFavoritesService.setMockLikedMovies([])

        // When
        let result = try await sut.loadFavoriteMovies().async()

        // Then
        #expect(result.isEmpty)
    }

    @Test("Toggle movie favorite adds movie to favorites when not already liked")
    func toggleMovieLikeAddMovie() async throws {
        // Given
        let movie = Movie(id: 999, title: "Test Movie", overview: "Test Overview", posterPath: "/test.jpg")
        let mockFavoritesService = MockFavoritesService()
        let sut: FavoritesService = mockFavoritesService

        // Clear pre-populated mock data to start fresh
        mockFavoritesService.setMockLikedMovies([])

        // When
        let result = try await sut.toggleMovieFavorite(movie).async()

        // Then
        #expect(result.count == 1)
        #expect(result.first == movie)
    }

    @Test("Toggle movie favorite removes movie from favorites when already liked")
    func toggleMovieLikeRemoveMovie() async throws {
        // Given
        let movie = Movie(id: 998, title: "Test Movie", overview: "Test Overview", posterPath: "/test.jpg")
        let mockFavoritesService = MockFavoritesService()
        let sut: FavoritesService = mockFavoritesService

        // Clear pre-populated mock data to start fresh
        mockFavoritesService.setMockLikedMovies([])

        // When - First add the movie
        let addResult = try await sut.toggleMovieFavorite(movie).async()

        // Then toggle again to remove
        let removeResult = try await sut.toggleMovieFavorite(movie).async()

        // Then
        #expect(addResult.count == 1)
        #expect(removeResult.isEmpty)
    }

    @Test("Clear all favorite movies removes all saved favorites")
    func clearAllLikedMovies() async throws {
        // Given
        let movie = Movie(id: 1, title: "Test Movie", overview: "Test Overview", posterPath: "/test.jpg")
        let mockFavoritesService = MockFavoritesService()
        let sut: FavoritesService = mockFavoritesService

        // When - First add a movie
        _ = try await sut.toggleMovieFavorite(movie).async()

        // Then clear all
        _ = try await sut.clearAllFavoriteMovies().async()

        // Then load to verify
        let loadResult = try await sut.loadFavoriteMovies().async()

        // Then
        #expect(loadResult.isEmpty)
    }

    @Test("Is movie liked correctly identifies liked and not liked movies")
    func isMovieLiked() async throws {
        // Given
        let movie1 = Movie(id: 997, title: "Test Movie 1", overview: "Test Overview 1", posterPath: "/test1.jpg")
        let movie2 = Movie(id: 996, title: "Test Movie 2", overview: "Test Overview 2", posterPath: "/test2.jpg")
        let mockFavoritesService = MockFavoritesService()
        let sut: FavoritesService = mockFavoritesService

        // Clear pre-populated mock data to start fresh
        mockFavoritesService.setMockLikedMovies([])

        // When - Add movie1
        _ = try await sut.toggleMovieFavorite(movie1).async()

        // Then check if movies are liked
        let isMovie1Liked = try await sut.isMovieLiked(movie1).async()
        let isMovie2Liked = try await sut.isMovieLiked(movie2).async()

        // Then
        #expect(isMovie1Liked)
        #expect(!isMovie2Liked)
    }
}
