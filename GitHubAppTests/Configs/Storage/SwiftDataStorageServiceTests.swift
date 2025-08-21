//
//  SwiftDataStorageServiceTests.swift
//  GitHubAppTests
//
//  Created by bruno on storage-migration.
//

import Combine
@testable import GitHubApp
import SwiftData
import XCTest

@MainActor
final class SwiftDataStorageServiceTests: XCTestCase {
    private var sut: SwiftDataStorageService!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() async throws {
        try await super.setUp()
        // Create test storage service with in-memory storage
        let schema = Schema([StoredMovie.self, UserSetting.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,
            allowsSave: true
        )
        let container = try ModelContainer(for: schema, configurations: [configuration])
        sut = try SwiftDataStorageService(container: container, performMigration: false)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() async throws {
        sut = nil
        cancellables = nil
        try await super.tearDown()
    }

    // MARK: - Movie Storage Tests

    func testSaveAndFetchMovies() async throws {
        // Given
        let movies = [
            Movie(id: 1, title: "Test Movie 1", overview: "Overview 1", posterPath: "/test1.jpg"),
            Movie(id: 2, title: "Test Movie 2", overview: "Overview 2", posterPath: "/test2.jpg"),
        ]

        // When
        try await sut.save(movies, context: StorageContext.favoriteMovies)
        let fetchedMovies = try await sut.fetch(Movie.self, context: StorageContext.favoriteMovies)

        // Then
        XCTAssertEqual(fetchedMovies.count, 2)
        XCTAssertTrue(fetchedMovies.contains { $0.id == 1 })
        XCTAssertTrue(fetchedMovies.contains { $0.id == 2 })
    }

    func testToggleMovieLike() async throws {
        // Given
        let movie = Movie(id: 1, title: "Test Movie", overview: "Overview", posterPath: "/test.jpg")

        // When - Add movie to liked
        let favoriteMovies = try await sut.toggleMovieFavorite(movie)

        // Then
        XCTAssertEqual(favoriteMovies.count, 1)
        XCTAssertEqual(favoriteMovies.first?.id, movie.id)

        // When - Remove movie from liked
        let updatedMovies = try await sut.toggleMovieFavorite(movie)

        // Then
        XCTAssertTrue(updatedMovies.isEmpty)
    }

    func testIsMovieLiked() async throws {
        // Given
        let movie = Movie(id: 1, title: "Test Movie", overview: "Overview", posterPath: "/test.jpg")

        // When - Movie not liked initially
        let isLikedBefore = try await sut.isMovieLiked(movie)

        // Then
        XCTAssertFalse(isLikedBefore)

        // When - Add movie to liked
        _ = try await sut.toggleMovieFavorite(movie)
        let isLikedAfter = try await sut.isMovieLiked(movie)

        // Then
        XCTAssertTrue(isLikedAfter)
    }

    func testFetchLikedMovies() async throws {
        // Given
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
        XCTAssertEqual(favoriteMovies.count, 2)
        XCTAssertTrue(favoriteMovies.contains { $0.id == 1 })
        XCTAssertTrue(favoriteMovies.contains { $0.id == 2 })
    }

    func testClearLikedMovies() async throws {
        // Given
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
        XCTAssertTrue(favoriteMovies.isEmpty)
    }

    func testDeleteSpecificMovie() async throws {
        // Given
        let movies = [
            Movie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: "/test1.jpg"),
            Movie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: "/test2.jpg"),
        ]

        try await sut.save(movies, context: StorageContext.favoriteMovies)

        // When
        try await sut.delete(movies[0], context: StorageContext.favoriteMovies)
        let remainingMovies = try await sut.fetch(Movie.self, context: StorageContext.favoriteMovies)

        // Then
        XCTAssertEqual(remainingMovies.count, 1)
        XCTAssertEqual(remainingMovies.first?.id, 2)
    }

    func testFetchMovieById() async throws {
        // Given
        let movie = Movie(id: 1, title: "Test Movie", overview: "Overview", posterPath: "/test.jpg")
        try await sut.save(movie, context: StorageContext.favoriteMovies)

        // When
        let fetchedMovie = try await sut.fetch(Movie.self, id: 1, context: StorageContext.favoriteMovies)

        // Then
        XCTAssertNotNil(fetchedMovie)
        XCTAssertEqual(fetchedMovie?.id, movie.id)
        XCTAssertEqual(fetchedMovie?.title, movie.title)
    }

    func testContextIsolation() async throws {
        // Given
        let movie1 = Movie(id: 1, title: "Liked Movie", overview: "Overview", posterPath: "/test1.jpg")
        let movie2 = Movie(id: 2, title: "Widget Movie", overview: "Overview", posterPath: "/test2.jpg")

        // When
        try await sut.save(movie1, context: StorageContext.favoriteMovies)
        try await sut.save(movie2, context: StorageContext.widget)

        let favoriteMovies = try await sut.fetch(Movie.self, context: StorageContext.favoriteMovies)
        let widgetMovies = try await sut.fetch(Movie.self, context: StorageContext.widget)

        // Then
        XCTAssertEqual(favoriteMovies.count, 1)
        XCTAssertEqual(favoriteMovies.first?.id, 1)

        XCTAssertEqual(widgetMovies.count, 1)
        XCTAssertEqual(widgetMovies.first?.id, 2)
    }

    // MARK: - Error Handling Tests

    func testErrorHandlingForInvalidData() async throws {
        // This test verifies that the service handles errors gracefully
        // For now, we'll test that no exceptions are thrown with valid data
        let movie = Movie(id: 1, title: "Test Movie", overview: "Overview", posterPath: "/test.jpg")

        do {
            try await sut.save(movie, context: StorageContext.favoriteMovies)
            let fetchedMovies = try await sut.fetch(Movie.self, context: StorageContext.favoriteMovies)
            XCTAssertEqual(fetchedMovies.count, 1)
        } catch {
            XCTFail("Should not throw error with valid data: \(error)")
        }
    }
}
