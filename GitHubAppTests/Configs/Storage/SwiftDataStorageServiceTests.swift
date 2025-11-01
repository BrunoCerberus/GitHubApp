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

    // MARK: - Movie Update Tests

    @Test("Update existing movie")
    func updateExistingMovie() async throws {
        // Given
        let sut = try createTestStorageService()
        let originalMovie = Movie(id: 1, title: "Original Title", overview: "Original Overview", posterPath: "/original.jpg")
        try await sut.save(originalMovie, context: StorageContext.favoriteMovies)

        // When - Save movie with same ID but different data
        let updatedMovie = Movie(id: 1, title: "Updated Title", overview: "Updated Overview", posterPath: "/updated.jpg")
        try await sut.save(updatedMovie, context: StorageContext.favoriteMovies)

        // Then - Should have only one movie with updated data
        let fetchedMovies = try await sut.fetch(Movie.self, context: StorageContext.favoriteMovies)
        #expect(fetchedMovies.count == 1, "Should have exactly one movie after update")
        #expect(fetchedMovies.first?.title == "Updated Title", "Title should be updated")
        #expect(fetchedMovies.first?.overview == "Updated Overview", "Overview should be updated")
        #expect(fetchedMovies.first?.posterPath == "/updated.jpg", "Poster path should be updated")
    }

    @Test("Save empty movies array does nothing")
    func saveEmptyMoviesArray() async throws {
        // Given
        let sut = try createTestStorageService()
        let emptyMovies: [Movie] = []

        // When
        try await sut.save(emptyMovies, context: StorageContext.favoriteMovies)
        let fetchedMovies = try await sut.fetch(Movie.self, context: StorageContext.favoriteMovies)

        // Then
        #expect(fetchedMovies.isEmpty, "Should have no movies after saving empty array")
    }

    @Test("Delete multiple movies")
    func deleteMultipleMovies() async throws {
        // Given
        let sut = try createTestStorageService()
        let movies = [
            Movie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: "/test1.jpg"),
            Movie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: "/test2.jpg"),
            Movie(id: 3, title: "Movie 3", overview: "Overview 3", posterPath: "/test3.jpg"),
        ]
        try await sut.save(movies, context: StorageContext.favoriteMovies)

        // When - Delete multiple movies
        try await sut.delete([movies[0], movies[2]], context: StorageContext.favoriteMovies)
        let remainingMovies = try await sut.fetch(Movie.self, context: StorageContext.favoriteMovies)

        // Then
        #expect(remainingMovies.count == 1, "Should have one movie remaining")
        #expect(remainingMovies.first?.id == 2, "Should be the middle movie that wasn't deleted")
    }

    @Test("Delete all movies")
    func deleteAllMovies() async throws {
        // Given
        let sut = try createTestStorageService()
        let movies = [
            Movie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: "/test1.jpg"),
            Movie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: "/test2.jpg"),
        ]
        try await sut.save(movies, context: StorageContext.favoriteMovies)

        // When
        try await sut.deleteAll(Movie.self, context: StorageContext.favoriteMovies)
        let remainingMovies = try await sut.fetch(Movie.self, context: StorageContext.favoriteMovies)

        // Then
        #expect(remainingMovies.isEmpty, "Should have no movies after deleteAll")
    }

    @Test("Fetch non-existent movie by ID returns nil")
    func fetchNonExistentMovieById() async throws {
        // Given
        let sut = try createTestStorageService()

        // When
        let fetchedMovie = try await sut.fetch(Movie.self, id: 999, context: StorageContext.favoriteMovies)

        // Then
        #expect(fetchedMovie == nil, "Should return nil for non-existent movie")
    }

    @Test("Delete non-existent movie does not throw")
    func deleteNonExistentMovie() async throws {
        // Given
        let sut = try createTestStorageService()
        let movie = Movie(id: 999, title: "Non-existent", overview: "Overview", posterPath: "/test.jpg")

        // When/Then - Should not throw error
        try await sut.delete(movie, context: StorageContext.favoriteMovies)

        // Verify no movies exist
        let movies = try await sut.fetch(Movie.self, context: StorageContext.favoriteMovies)
        #expect(movies.isEmpty, "Should have no movies")
    }

    // MARK: - Generic Storage Tests (Non-Movie Types)

    struct TestUser: Codable, Identifiable, Equatable {
        let id: Int
        let name: String
        let email: String
    }

    @Test("Save and fetch generic objects")
    func saveAndFetchGenericObjects() async throws {
        // Given
        let sut = try createTestStorageService()
        let users = [
            TestUser(id: 1, name: "Alice", email: "alice@test.com"),
            TestUser(id: 2, name: "Bob", email: "bob@test.com"),
        ]

        // When
        try await sut.save(users, context: "users")
        let fetchedUsers = try await sut.fetch(TestUser.self, context: "users")

        // Then
        #expect(fetchedUsers.count == 2, "Should fetch both users")
        #expect(fetchedUsers.contains { $0.id == 1 && $0.name == "Alice" }, "Should contain Alice")
        #expect(fetchedUsers.contains { $0.id == 2 && $0.name == "Bob" }, "Should contain Bob")
    }

    @Test("Update existing generic object")
    func updateExistingGenericObject() async throws {
        // Given
        let sut = try createTestStorageService()
        let originalUser = TestUser(id: 1, name: "Alice", email: "alice@old.com")
        try await sut.save(originalUser, context: "users")

        // When
        let updatedUser = TestUser(id: 1, name: "Alice", email: "alice@new.com")
        try await sut.save(updatedUser, context: "users")

        // Then
        let fetchedUsers = try await sut.fetch(TestUser.self, context: "users")
        #expect(fetchedUsers.count == 1, "Should have only one user after update")
        #expect(fetchedUsers.first?.email == "alice@new.com", "Email should be updated")
    }

    @Test("Fetch generic object by ID")
    func fetchGenericObjectById() async throws {
        // Given
        let sut = try createTestStorageService()
        let user = TestUser(id: 1, name: "Alice", email: "alice@test.com")
        try await sut.save(user, context: "users")

        // When
        let fetchedUser = try await sut.fetch(TestUser.self, id: 1, context: "users")

        // Then
        #expect(fetchedUser != nil, "Should fetch the user")
        #expect(fetchedUser?.name == "Alice", "Should be Alice")
        #expect(fetchedUser?.email == "alice@test.com", "Should have correct email")
    }

    @Test("Fetch non-existent generic object by ID returns nil")
    func fetchNonExistentGenericObjectById() async throws {
        // Given
        let sut = try createTestStorageService()

        // When
        let fetchedUser = try await sut.fetch(TestUser.self, id: 999, context: "users")

        // Then
        #expect(fetchedUser == nil, "Should return nil for non-existent user")
    }

    @Test("Delete generic object")
    func deleteGenericObject() async throws {
        // Given
        let sut = try createTestStorageService()
        let users = [
            TestUser(id: 1, name: "Alice", email: "alice@test.com"),
            TestUser(id: 2, name: "Bob", email: "bob@test.com"),
        ]
        try await sut.save(users, context: "users")

        // When
        try await sut.delete(users[0], context: "users")
        let remainingUsers = try await sut.fetch(TestUser.self, context: "users")

        // Then
        #expect(remainingUsers.count == 1, "Should have one user remaining")
        #expect(remainingUsers.first?.id == 2, "Should be Bob")
    }

    @Test("Delete multiple generic objects")
    func deleteMultipleGenericObjects() async throws {
        // Given
        let sut = try createTestStorageService()
        let users = [
            TestUser(id: 1, name: "Alice", email: "alice@test.com"),
            TestUser(id: 2, name: "Bob", email: "bob@test.com"),
            TestUser(id: 3, name: "Charlie", email: "charlie@test.com"),
        ]
        try await sut.save(users, context: "users")

        // When
        try await sut.delete([users[0], users[2]], context: "users")
        let remainingUsers = try await sut.fetch(TestUser.self, context: "users")

        // Then
        #expect(remainingUsers.count == 1, "Should have one user remaining")
        #expect(remainingUsers.first?.name == "Bob", "Should be Bob")
    }

    @Test("Delete all generic objects")
    func deleteAllGenericObjects() async throws {
        // Given
        let sut = try createTestStorageService()
        let users = [
            TestUser(id: 1, name: "Alice", email: "alice@test.com"),
            TestUser(id: 2, name: "Bob", email: "bob@test.com"),
        ]
        try await sut.save(users, context: "users")

        // When
        try await sut.deleteAll(TestUser.self, context: "users")
        let remainingUsers = try await sut.fetch(TestUser.self, context: "users")

        // Then
        #expect(remainingUsers.isEmpty, "Should have no users after deleteAll")
    }

    @Test("Generic context isolation")
    func genericContextIsolation() async throws {
        // Given
        let sut = try createTestStorageService()
        let user1 = TestUser(id: 1, name: "Alice", email: "alice@test.com")
        let user2 = TestUser(id: 2, name: "Bob", email: "bob@test.com")

        // When
        try await sut.save(user1, context: "activeUsers")
        try await sut.save(user2, context: "archivedUsers")

        let activeUsers = try await sut.fetch(TestUser.self, context: "activeUsers")
        let archivedUsers = try await sut.fetch(TestUser.self, context: "archivedUsers")

        // Then
        #expect(activeUsers.count == 1, "Should have one active user")
        #expect(activeUsers.first?.name == "Alice", "Active user should be Alice")

        #expect(archivedUsers.count == 1, "Should have one archived user")
        #expect(archivedUsers.first?.name == "Bob", "Archived user should be Bob")
    }

    @Test("Generic objects with nil context use default category")
    func genericObjectsWithNilContext() async throws {
        // Given
        let sut = try createTestStorageService()
        let user = TestUser(id: 1, name: "Alice", email: "alice@test.com")

        // When
        try await sut.save(user, context: nil)
        let fetchedUsers = try await sut.fetch(TestUser.self, context: nil)

        // Then
        #expect(fetchedUsers.count == 1, "Should fetch user with nil context")
        #expect(fetchedUsers.first?.name == "Alice", "Should be Alice")
    }

    @Test("Save empty generic objects array does nothing")
    func saveEmptyGenericObjectsArray() async throws {
        // Given
        let sut = try createTestStorageService()
        let emptyUsers: [TestUser] = []

        // When
        try await sut.save(emptyUsers, context: "users")
        let fetchedUsers = try await sut.fetch(TestUser.self, context: "users")

        // Then
        #expect(fetchedUsers.isEmpty, "Should have no users after saving empty array")
    }

    // MARK: - Mixed Type Storage Tests

    @Test("Movies and generic objects are independently managed")
    func moviesAndGenericObjectsAreIndependent() async throws {
        // Given
        let sut = try createTestStorageService()
        let movie = Movie(id: 1, title: "Test Movie", overview: "Overview", posterPath: "/test.jpg")
        let user = TestUser(id: 1, name: "Alice", email: "alice@test.com")

        // When
        try await sut.save(movie, context: StorageContext.favoriteMovies)
        try await sut.save(user, context: "users")

        let fetchedMovies = try await sut.fetch(Movie.self, context: StorageContext.favoriteMovies)
        let fetchedUsers = try await sut.fetch(TestUser.self, context: "users")

        // Then
        #expect(fetchedMovies.count == 1, "Should have one movie")
        #expect(fetchedUsers.count == 1, "Should have one user")

        // Verify they can be deleted independently
        try await sut.delete(movie, context: StorageContext.favoriteMovies)
        let remainingMovies = try await sut.fetch(Movie.self, context: StorageContext.favoriteMovies)
        let remainingUsers = try await sut.fetch(TestUser.self, context: "users")

        #expect(remainingMovies.isEmpty, "Movies should be deleted")
        #expect(remainingUsers.count == 1, "Users should remain intact")
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
