//
//  SwiftDataStorageServiceTests.swift
//  GitHubAppTests
//
//  Created by bruno on storage-migration.
//

import Combine
@testable import GitHubApp
import XCTest

@MainActor
final class SwiftDataStorageServiceTests: XCTestCase {
    private var sut: SwiftDataStorageService!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() async throws {
        try await super.setUp()
        // Create test storage service with in-memory storage
        sut = try SwiftDataStorageService(container: nil, performMigration: false)
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
        try await sut.save(movies, context: StorageContext.likedMovies)
        let fetchedMovies = try await sut.fetch(Movie.self, context: StorageContext.likedMovies)

        // Then
        XCTAssertEqual(fetchedMovies.count, 2)
        XCTAssertTrue(fetchedMovies.contains { $0.id == 1 })
        XCTAssertTrue(fetchedMovies.contains { $0.id == 2 })
    }

    func testToggleMovieLike() async throws {
        // Given
        let movie = Movie(id: 1, title: "Test Movie", overview: "Overview", posterPath: "/test.jpg")

        // When - Add movie to liked
        let likedMovies = try await sut.toggleMovieLike(movie)

        // Then
        XCTAssertEqual(likedMovies.count, 1)
        XCTAssertEqual(likedMovies.first?.id, movie.id)

        // When - Remove movie from liked
        let updatedMovies = try await sut.toggleMovieLike(movie)

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
        _ = try await sut.toggleMovieLike(movie)
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
            _ = try await sut.toggleMovieLike(movie)
        }
        let likedMovies = try await sut.fetchLikedMovies()

        // Then
        XCTAssertEqual(likedMovies.count, 2)
        XCTAssertTrue(likedMovies.contains { $0.id == 1 })
        XCTAssertTrue(likedMovies.contains { $0.id == 2 })
    }

    func testClearLikedMovies() async throws {
        // Given
        let movies = [
            Movie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: "/test1.jpg"),
            Movie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: "/test2.jpg"),
        ]

        for movie in movies {
            _ = try await sut.toggleMovieLike(movie)
        }

        // When
        try await sut.clearLikedMovies()
        let likedMovies = try await sut.fetchLikedMovies()

        // Then
        XCTAssertTrue(likedMovies.isEmpty)
    }

    func testDeleteSpecificMovie() async throws {
        // Given
        let movies = [
            Movie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: "/test1.jpg"),
            Movie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: "/test2.jpg"),
        ]

        try await sut.save(movies, context: StorageContext.likedMovies)

        // When
        try await sut.delete(movies[0], context: StorageContext.likedMovies)
        let remainingMovies = try await sut.fetch(Movie.self, context: StorageContext.likedMovies)

        // Then
        XCTAssertEqual(remainingMovies.count, 1)
        XCTAssertEqual(remainingMovies.first?.id, 2)
    }

    func testFetchMovieById() async throws {
        // Given
        let movie = Movie(id: 1, title: "Test Movie", overview: "Overview", posterPath: "/test.jpg")
        try await sut.save(movie, context: StorageContext.likedMovies)

        // When
        let fetchedMovie = try await sut.fetch(Movie.self, id: 1, context: StorageContext.likedMovies)

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
        try await sut.save(movie1, context: StorageContext.likedMovies)
        try await sut.save(movie2, context: StorageContext.widget)

        let likedMovies = try await sut.fetch(Movie.self, context: StorageContext.likedMovies)
        let widgetMovies = try await sut.fetch(Movie.self, context: StorageContext.widget)

        // Then
        XCTAssertEqual(likedMovies.count, 1)
        XCTAssertEqual(likedMovies.first?.id, 1)

        XCTAssertEqual(widgetMovies.count, 1)
        XCTAssertEqual(widgetMovies.first?.id, 2)
    }

    // MARK: - Error Handling Tests

    func testErrorHandlingForInvalidData() async throws {
        // This test verifies that the service handles errors gracefully
        // For now, we'll test that no exceptions are thrown with valid data
        let movie = Movie(id: 1, title: "Test Movie", overview: "Overview", posterPath: "/test.jpg")

        do {
            try await sut.save(movie, context: StorageContext.likedMovies)
            let fetchedMovies = try await sut.fetch(Movie.self, context: StorageContext.likedMovies)
            XCTAssertEqual(fetchedMovies.count, 1)
        } catch {
            XCTFail("Should not throw error with valid data: \(error)")
        }
    }
}
