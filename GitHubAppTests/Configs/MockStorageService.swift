//
//  MockStorageService.swift
//  GitHubAppTests
//
//  Created for testing purposes.
//

import Foundation
@testable import GitHubApp

/**
 * Mock implementation of StorageService for testing.
 *
 * @MainActor ensures thread-safe access to the mutable movies array
 * and prevents concurrent modification crashes.
 */
@MainActor
final class MockStorageService: StorageService {
    private var movies: [Movie] = []

    // MARK: - Error Simulation Properties

    var shouldSimulateErrors = false
    var fetchLikedMoviesError: Error?
    var toggleError: Error?
    var clearError: Error?
    var isMovieLikedError: Error?

    // MARK: - Test Result Customization

    var favoriteMovies: [Movie] = []
    var toggledMovies: [Movie] = []
    var movieLikedResult: Bool = false

    func save(_ object: some Codable & Identifiable, context _: String?) async throws {
        if let movie = object as? Movie {
            // Remove existing movie with same ID
            movies.removeAll { $0.id == movie.id }
            movies.append(movie)
        }
    }

    func save(_ objects: [some Codable & Identifiable], context: String?) async throws {
        for object in objects {
            try await save(object, context: context)
        }
    }

    func fetch<T: Codable & Identifiable>(_ type: T.Type, context _: String?) async throws -> [T] {
        if type == Movie.self {
            // swiftlint:disable:next force_cast
            return movies as! [T]
        }
        return []
    }

    func fetch<T: Codable & Identifiable>(_ type: T.Type, id: T.ID, context: String?) async throws -> T? {
        let objects = try await fetch(type, context: context)
        return objects.first { $0.id == id }
    }

    func delete(_ objects: [some Codable & Identifiable], context: String?) async throws {
        for object in objects {
            try await delete(object, context: context)
        }
    }

    func delete(_ object: some Codable & Identifiable, context _: String?) async throws {
        if let movie = object as? Movie {
            movies.removeAll { $0.id == movie.id }
        }
    }

    func deleteAll(_ type: (some Codable & Identifiable).Type, context _: String?) async throws {
        if type == Movie.self {
            movies.removeAll()
        }
    }

    func isMovieLiked(_ movie: Movie) async throws -> Bool {
        if shouldSimulateErrors, let error = isMovieLikedError {
            throw error
        }
        // If movieLikedResult is set (true), use it; otherwise check actual movies
        if movieLikedResult {
            return movieLikedResult
        }
        return movies.contains { $0.id == movie.id }
    }

    func toggleMovieFavorite(_ movie: Movie) async throws -> [Movie] {
        if shouldSimulateErrors, let error = toggleError {
            throw error
        }

        if !toggledMovies.isEmpty {
            return toggledMovies
        }

        let isLiked = try await isMovieLiked(movie)
        if isLiked {
            try await delete(movie, context: StorageContext.favoriteMovies)
        } else {
            try await save(movie, context: StorageContext.favoriteMovies)
        }
        return try await fetchLikedMovies()
    }

    func fetchLikedMovies() async throws -> [Movie] {
        if shouldSimulateErrors, let error = fetchLikedMoviesError {
            throw error
        }
        return !favoriteMovies.isEmpty ? favoriteMovies : movies
    }

    func clearFavoriteMovies() async throws {
        if shouldSimulateErrors, let error = clearError {
            throw error
        }
        movies.removeAll()
    }
}
