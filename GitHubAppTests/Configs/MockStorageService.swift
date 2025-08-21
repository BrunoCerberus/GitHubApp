//
//  MockStorageService.swift
//  GitHubAppTests
//
//  Created for testing purposes.
//

import Foundation
@testable import GitHubApp

/**
 * Mock implementation of StorageServiceProtocol for testing.
 */
final class MockStorageService: StorageServiceProtocol {
    private var movies: [Movie] = []

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
        movies.contains { $0.id == movie.id }
    }

    func toggleMovieLike(_ movie: Movie) async throws -> [Movie] {
        let isLiked = try await isMovieLiked(movie)
        if isLiked {
            try await delete(movie, context: StorageContext.likedMovies)
        } else {
            try await save(movie, context: StorageContext.likedMovies)
        }
        return try await fetchLikedMovies()
    }

    func fetchLikedMovies() async throws -> [Movie] {
        movies
    }

    func clearLikedMovies() async throws {
        movies.removeAll()
    }
}
