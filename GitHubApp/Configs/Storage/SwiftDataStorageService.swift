//
//  SwiftDataStorageService.swift
//  GitHubApp
//
//  Created by bruno on storage-migration.
//

import Foundation
import SwiftData

/**
 * SwiftData-based implementation of StorageService.
 *
 * This service provides a modern, efficient data persistence layer using SwiftData,
 * replacing the previous UserDefaults-based approach. It supports generic CRUD
 * operations and specialized movie-related functionality.
 *
 * Features:
 * - Generic object storage with type safety
 * - Context-based data organization
 * - Optimized movie operations for favorite movies
 * - Automatic migration from UserDefaults
 * - Thread-safe operations
 */
final class SwiftDataStorageService: StorageService {
    // MARK: - Properties

    /// SwiftData model container
    private let container: ModelContainer

    /// SwiftData model context for database operations
    private let context: ModelContext

    // MARK: - Initialization

    /**
     * Initialize the SwiftData storage service.
     *
     * - Parameters:
     *   - container: Optional model container (creates default if nil)
     * - Throws: StorageError if initialization fails
     */
    init(container: ModelContainer? = nil) throws {
        do {
            // Set up SwiftData container and context
            if let container {
                self.container = container
            } else {
                let schema = Schema([StoredMovie.self, UserSetting.self])
                let configuration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false,
                    allowsSave: true
                )
                self.container = try ModelContainer(for: schema, configurations: [configuration])
            }

            context = ModelContext(self.container)
        } catch {
            throw StorageError.saveFailure("Failed to initialize SwiftDataStorageService: \(error.localizedDescription)")
        }
    }

    // MARK: - Generic CRUD Operations

    @MainActor
    func save<T: Codable & Identifiable>(_ object: T, context: String?) async throws {
        do {
            if let movie = object as? Movie {
                try await saveMovie(movie, context: context ?? StorageContext.favoriteMovies)
            } else {
                // For other types, use UserSetting storage
                let key = "\(T.self)_\(object.id)"
                let category = context ?? "generic"
                let setting = try UserSetting(key: key, value: object, category: category)
                self.context.insert(setting)
                try self.context.save()
            }
        } catch {
            throw StorageError.saveFailure("Failed to save \(T.self): \(error.localizedDescription)")
        }
    }

    @MainActor
    func save(_ objects: [some Codable & Identifiable], context: String?) async throws {
        for object in objects {
            try await save(object, context: context)
        }
    }

    nonisolated func fetch<T: Codable & Identifiable>(_ type: T.Type, context: String?) async throws -> [T] {
        try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                do {
                    if type == Movie.self {
                        let movies = try await self.fetchMovies(context: context ?? StorageContext.favoriteMovies)
                        continuation.resume(returning: movies as! [T])
                    } else {
                        // For other types, fetch from UserSetting
                        let category = context ?? "generic"
                        let predicate = UserSetting.categoryPredicate(category)
                        let descriptor = FetchDescriptor<UserSetting>(predicate: predicate)
                        let settings = try self.context.fetch(descriptor)

                        let result = settings.compactMap { setting in
                            try? setting.getValue(as: type)
                        }
                        continuation.resume(returning: result)
                    }
                } catch {
                    continuation.resume(throwing: StorageError.fetchFailure("Failed to fetch \(type): \(error.localizedDescription)"))
                }
            }
        }
    }

    nonisolated func fetch<T: Codable & Identifiable>(_ type: T.Type, id: T.ID, context: String?) async throws -> T? {
        let objects = try await fetch(type, context: context)
        return objects.first { $0.id == id }
    }

    @MainActor
    func delete(_ objects: [some Codable & Identifiable], context: String?) async throws {
        for object in objects {
            try await delete(object, context: context)
        }
    }

    @MainActor
    func delete<T: Codable & Identifiable>(_ object: T, context: String?) async throws {
        do {
            if let movie = object as? Movie {
                try await deleteMovie(movie, context: context ?? StorageContext.favoriteMovies)
            } else {
                // For other types, delete from UserSetting
                let key = "\(T.self)_\(object.id)"
                let predicate = UserSetting.keyPredicate(key)
                let descriptor = FetchDescriptor<UserSetting>(predicate: predicate)
                let settings = try self.context.fetch(descriptor)

                for setting in settings {
                    self.context.delete(setting)
                }
                try self.context.save()
            }
        } catch {
            throw StorageError.deleteFailure("Failed to delete \(T.self): \(error.localizedDescription)")
        }
    }

    nonisolated func deleteAll(_ type: (some Codable & Identifiable).Type, context: String?) async throws {
        try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                do {
                    if type == Movie.self {
                        try await self.clearMovies(context: context ?? StorageContext.favoriteMovies)
                        continuation.resume()
                    } else {
                        // For other types, delete all from category
                        let category = context ?? "generic"
                        let predicate = UserSetting.categoryPredicate(category)
                        let descriptor = FetchDescriptor<UserSetting>(predicate: predicate)
                        let settings = try self.context.fetch(descriptor)

                        for setting in settings {
                            self.context.delete(setting)
                        }
                        try self.context.save()
                        continuation.resume()
                    }
                } catch {
                    continuation.resume(throwing: StorageError.deleteFailure("Failed to delete all \(type): \(error.localizedDescription)"))
                }
            }
        }
    }

    // MARK: - Specialized Movie Operations

    @MainActor
    func isMovieLiked(_ movie: Movie) async throws -> Bool {
        do {
            let predicate = StoredMovie.moviePredicate(movieID: movie.id, context: StorageContext.favoriteMovies)
            let descriptor = FetchDescriptor<StoredMovie>(predicate: predicate)
            let results = try context.fetch(descriptor)
            return !results.isEmpty
        } catch {
            throw StorageError.fetchFailure("Failed to check if movie is liked: \(error.localizedDescription)")
        }
    }

    @MainActor
    func toggleMovieFavorite(_ movie: Movie) async throws -> [Movie] {
        do {
            let isLiked = try await isMovieLiked(movie)

            if isLiked {
                try await deleteMovie(movie, context: StorageContext.favoriteMovies)
            } else {
                try await saveMovie(movie, context: StorageContext.favoriteMovies)
            }

            return try await fetchLikedMovies()
        } catch {
            throw StorageError.saveFailure("Failed to toggle movie like: \(error.localizedDescription)")
        }
    }

    @MainActor
    func fetchLikedMovies() async throws -> [Movie] {
        try await fetchMovies(context: StorageContext.favoriteMovies)
    }

    @MainActor
    func clearFavoriteMovies() async throws {
        try await clearMovies(context: StorageContext.favoriteMovies)
    }

    // MARK: - Private Movie Helpers

    @MainActor
    private func saveMovie(_ movie: Movie, context: String) async throws {
        // Check if movie already exists
        let predicate = StoredMovie.moviePredicate(movieID: movie.id, context: context)
        let descriptor = FetchDescriptor<StoredMovie>(predicate: predicate)
        let existingMovies = try self.context.fetch(descriptor)

        if let existingMovie = existingMovies.first {
            // Update existing movie
            existingMovie.update(from: movie)
        } else {
            // Insert new movie
            let storedMovie = StoredMovie(from: movie, context: context)
            self.context.insert(storedMovie)
        }

        try self.context.save()
    }

    @MainActor
    private func fetchMovies(context: String) async throws -> [Movie] {
        let predicate = StoredMovie.contextPredicate(context)
        let descriptor = FetchDescriptor<StoredMovie>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        let storedMovies = try self.context.fetch(descriptor)
        return storedMovies.map { $0.toMovie() }
    }

    @MainActor
    private func deleteMovie(_ movie: Movie, context: String) async throws {
        let predicate = StoredMovie.moviePredicate(movieID: movie.id, context: context)
        let descriptor = FetchDescriptor<StoredMovie>(predicate: predicate)
        let storedMovies = try self.context.fetch(descriptor)

        for storedMovie in storedMovies {
            self.context.delete(storedMovie)
        }

        try self.context.save()
    }

    @MainActor
    private func clearMovies(context: String) async throws {
        let predicate = StoredMovie.contextPredicate(context)
        let descriptor = FetchDescriptor<StoredMovie>(predicate: predicate)
        let storedMovies = try self.context.fetch(descriptor)

        for storedMovie in storedMovies {
            self.context.delete(storedMovie)
        }

        try self.context.save()
    }
}
