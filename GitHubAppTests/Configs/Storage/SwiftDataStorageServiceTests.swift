//
//  SwiftDataStorageServiceTests.swift
//  GitHubAppTests
//
//  Created by bruno on storage-migration.
//

import Combine
@testable import GitHubApp
import SwiftData
import Testing

@MainActor
struct SwiftDataStorageServiceTests {
    private func createTestStorageService() throws -> SwiftDataStorageService {
        // Create test storage service with in-memory storage
        let schema = Schema([StoredMovie.self, UserSetting.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,
            allowsSave: true
        )
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return try SwiftDataStorageService(container: container)
    }

    // MARK: - Movie Storage Tests

    @Test("Save and fetch movies")
    func saveAndFetchMovies() async throws {
        // Given
        let sut = try createTestStorageService()
        let movies = [
            Movie(id: 1, title: "Test Movie 1", overview: "Overview 1", posterPath: "/test1.jpg"),
            Movie(id: 2, title: "Test Movie 2", overview: "Overview 2", posterPath: "/test2.jpg"),
        ]

        // When
        try await sut.save(movies, context: StorageContext.favoriteMovies)
        let fetchedMovies = try await sut.fetch(Movie.self, context: StorageContext.favoriteMovies)

        // Then
        #expect(fetchedMovies.count == 2)
        #expect(fetchedMovies.contains { $0.id == 1 })
        #expect(fetchedMovies.contains { $0.id == 2 })
    }

    @Test("Toggle movie like")
    func toggleMovieLike() async throws {
        // Given
        let sut = try createTestStorageService()
        let movie = Movie(id: 1, title: "Test Movie", overview: "Overview", posterPath: "/test.jpg")

        // When - Add movie to liked
        let favoriteMovies = try await sut.toggleMovieFavorite(movie)

        // Then
        #expect(favoriteMovies.count == 1)
        #expect(favoriteMovies.first?.id == movie.id)

        // When - Remove movie from liked
        let updatedMovies = try await sut.toggleMovieFavorite(movie)

        // Then
        #expect(updatedMovies.isEmpty)
    }

    @Test("Is movie liked")
    func isMovieLiked() async throws {
        // Given
        let sut = try createTestStorageService()
        let movie = Movie(id: 1, title: "Test Movie", overview: "Overview", posterPath: "/test.jpg")

        // When - Movie not liked initially
        let isLikedBefore = try await sut.isMovieLiked(movie)

        // Then
        #expect(isLikedBefore == false)

        // When - Add movie to liked
        _ = try await sut.toggleMovieFavorite(movie)
        let isLikedAfter = try await sut.isMovieLiked(movie)

        // Then
        #expect(isLikedAfter == true)
    }

    @Test("Fetch liked movies")
    func fetchLikedMovies() async throws {
        // Given
        let sut = try createTestStorageService()
        let movies = [
            Movie(id: 1, title: "Liked Movie 1", overview: "Overview 1", posterPath: "/test1.jpg"),
            Movie(id: 2, title: "Liked Movie 2", overview: "Overview 2", posterPath: "/test2.jpg"),
        ]

        // When
        for movie in movies {
            _ = try await sut.toggleMovieFavorite(movie)
        }
        let favoriteMovies = try await sut.fetchLikedMovies()

        // Then
        #expect(favoriteMovies.count == 2)
        #expect(favoriteMovies.contains { $0.id == 1 })
        #expect(favoriteMovies.contains { $0.id == 2 })
    }

    @Test("Clear liked movies")
    func clearLikedMovies() async throws {
        // Given
        let sut = try createTestStorageService()
        let movies = [
            Movie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: "/test1.jpg"),
            Movie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: "/test2.jpg"),
        ]

        for movie in movies {
            _ = try await sut.toggleMovieFavorite(movie)
        }

        // When
        try await sut.clearFavoriteMovies()
        let favoriteMovies = try await sut.fetchLikedMovies()

        // Then
        #expect(favoriteMovies.isEmpty)
    }

    @Test("Delete specific movie")
    func deleteSpecificMovie() async throws {
        // Given
        let sut = try createTestStorageService()
        let movies = [
            Movie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: "/test1.jpg"),
            Movie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: "/test2.jpg"),
        ]

        try await sut.save(movies, context: StorageContext.favoriteMovies)

        // When
        try await sut.delete(movies[0], context: StorageContext.favoriteMovies)
        let remainingMovies = try await sut.fetch(Movie.self, context: StorageContext.favoriteMovies)

        // Then
        #expect(remainingMovies.count == 1)
        #expect(remainingMovies.first?.id == 2)
    }

    @Test("Fetch movie by id")
    func fetchMovieById() async throws {
        // Given
        let sut = try createTestStorageService()
        let movie = Movie(id: 1, title: "Test Movie", overview: "Overview", posterPath: "/test.jpg")
        try await sut.save(movie, context: StorageContext.favoriteMovies)

        // When
        let fetchedMovie = try await sut.fetch(Movie.self, id: 1, context: StorageContext.favoriteMovies)

        // Then
        #expect(fetchedMovie != nil)
        #expect(fetchedMovie?.id == movie.id)
        #expect(fetchedMovie?.title == movie.title)
    }

    @Test("Context isolation")
    func contextIsolation() async throws {
        // Given
        let sut = try createTestStorageService()
        let movie1 = Movie(id: 1, title: "Liked Movie", overview: "Overview", posterPath: "/test1.jpg")
        let movie2 = Movie(id: 2, title: "Widget Movie", overview: "Overview", posterPath: "/test2.jpg")

        // When
        try await sut.save(movie1, context: StorageContext.favoriteMovies)
        try await sut.save(movie2, context: StorageContext.widget)

        let favoriteMovies = try await sut.fetch(Movie.self, context: StorageContext.favoriteMovies)
        let widgetMovies = try await sut.fetch(Movie.self, context: StorageContext.widget)

        // Then
        #expect(favoriteMovies.count == 1)
        #expect(favoriteMovies.first?.id == 1)

        #expect(widgetMovies.count == 1)
        #expect(widgetMovies.first?.id == 2)
    }

    // MARK: - Error Handling Tests

    @Test("Error handling for invalid data")
    func errorHandlingForInvalidData() async throws {
        // Given
        let sut = try createTestStorageService()
        let movie = Movie(id: 1, title: "Test Movie", overview: "Overview", posterPath: "/test.jpg")

        // When
        try await sut.save(movie, context: StorageContext.favoriteMovies)
        let fetchedMovies = try await sut.fetch(Movie.self, context: StorageContext.favoriteMovies)

        // Then
        #expect(fetchedMovies.count == 1)
    }
}
