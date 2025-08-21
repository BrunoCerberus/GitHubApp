//
//  StorageServiceFactory.swift
//  GitHubApp
//
//  Created by bruno on storage-migration.
//

import Foundation
import SwiftData

/**
 * Factory for creating and managing StorageService instances.
 *
 * This factory provides a centralized way to create and configure
 * storage services throughout the application, supporting both
 * production and testing scenarios.
 */
final class StorageServiceFactory {
    // MARK: - Singleton

    static let shared = StorageServiceFactory()

    // MARK: - Properties

    /// Cached storage service instance
    private var cachedStorageService: StorageServiceProtocol?

    /// Configuration for the storage service
    private var configuration: StorageConfiguration

    // MARK: - Initialization

    private init(configuration: StorageConfiguration = .production) {
        self.configuration = configuration
    }

    // MARK: - Public Methods

    /**
     * Get the shared storage service instance.
     *
     * Creates a new instance if one doesn't exist, otherwise returns
     * the cached instance for consistency throughout the app lifecycle.
     *
     * - Returns: Configured storage service
     * - Throws: StorageError if creation fails
     */
    func getStorageService() throws -> StorageServiceProtocol {
        if let cachedService = cachedStorageService {
            return cachedService
        }

        let service = try createStorageService()
        cachedStorageService = service
        return service
    }

    /**
     * Create a new storage service instance for testing.
     *
     * This method creates a fresh instance with in-memory storage,
     * ideal for unit tests that need isolation.
     *
     * - Returns: New storage service configured for testing
     * - Throws: StorageError if creation fails
     */
    func createTestStorageService() throws -> StorageServiceProtocol {
        let testConfiguration = StorageConfiguration.testing
        return try createStorageService(configuration: testConfiguration)
    }

    /**
     * Reset the cached storage service.
     *
     * Forces creation of a new instance on the next call to getStorageService().
     * Useful for testing or configuration changes.
     */
    func resetCache() {
        cachedStorageService = nil
    }

    /**
     * Update the factory configuration.
     *
     * - Parameter configuration: New storage configuration
     */
    func updateConfiguration(_ configuration: StorageConfiguration) {
        self.configuration = configuration
        resetCache()
    }

    // MARK: - Private Methods

    private func createStorageService(configuration: StorageConfiguration? = nil) throws -> StorageServiceProtocol {
        let config = configuration ?? self.configuration

        switch config.type {
        case .swiftData:
            let container = try createModelContainer(for: config)
            return try SwiftDataStorageService(
                container: container,
                performMigration: config.performMigration
            )
        case .userDefaults:
            // Fallback to UserDefaults-based service (for legacy support)
            return UserDefaultsStorageService()
        }
    }

    private func createModelContainer(for configuration: StorageConfiguration) throws -> ModelContainer {
        let schema = Schema([StoredMovie.self, UserSetting.self])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: configuration.isInMemory,
            allowsSave: true
        )

        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    }
}

// MARK: - Storage Configuration

/**
 * Configuration options for storage services.
 */
struct StorageConfiguration {
    enum StorageType {
        case swiftData
        case userDefaults
    }

    let type: StorageType
    let isInMemory: Bool
    let performMigration: Bool

    /// Production configuration with persistent SwiftData storage
    static let production = StorageConfiguration(
        type: .swiftData,
        isInMemory: false,
        performMigration: true
    )

    /// Testing configuration with in-memory storage
    static let testing = StorageConfiguration(
        type: .swiftData,
        isInMemory: true,
        performMigration: false
    )

    /// Legacy configuration using UserDefaults
    static let legacy = StorageConfiguration(
        type: .userDefaults,
        isInMemory: false,
        performMigration: false
    )
}

// MARK: - Legacy UserDefaults Service

/**
 * Legacy UserDefaults-based storage service for backward compatibility.
 *
 * This service maintains the existing UserDefaults-based storage
 * and can serve as a fallback if SwiftData is not available.
 */
final class UserDefaultsStorageService: StorageServiceProtocol {
    private let userDefaults: UserDefaults
    private let favoriteMoviesKey = "favoriteMoviesKey"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Generic CRUD Operations (Limited Implementation)

    func save(_ object: some Codable & Identifiable, context _: String?) async throws {
        if let movie = object as? Movie {
            var movies = try await fetchLikedMovies()
            if !movies.contains(where: { $0.id == movie.id }) {
                movies.append(movie)
                try saveMoviesToUserDefaults(movies)
            }
        }
        // Other types not supported in legacy mode
    }

    func save(_ objects: [some Codable & Identifiable], context: String?) async throws {
        for object in objects {
            try await save(object, context: context)
        }
    }

    func fetch<T: Codable & Identifiable>(_ type: T.Type, context _: String?) async throws -> [T] {
        if type == Movie.self {
            let movies = try await fetchLikedMovies()
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
            var movies = try await fetchLikedMovies()
            movies.removeAll { $0.id == movie.id }
            try saveMoviesToUserDefaults(movies)
        }
    }

    func deleteAll(_ type: (some Codable & Identifiable).Type, context _: String?) async throws {
        if type == Movie.self {
            try await clearFavoriteMovies()
        }
    }

    // MARK: - Movie Operations

    func isMovieLiked(_ movie: Movie) async throws -> Bool {
        let movies = try await fetchLikedMovies()
        return movies.contains { $0.id == movie.id }
    }

    func toggleMovieFavorite(_ movie: Movie) async throws -> [Movie] {
        var movies = try await fetchLikedMovies()

        if let index = movies.firstIndex(where: { $0.id == movie.id }) {
            movies.remove(at: index)
        } else {
            movies.append(movie)
        }

        try saveMoviesToUserDefaults(movies)
        return movies
    }

    func fetchLikedMovies() async throws -> [Movie] {
        guard let data = userDefaults.data(forKey: favoriteMoviesKey),
              let movies = try? JSONDecoder().decode([Movie].self, from: data)
        else {
            return []
        }
        return movies
    }

    func clearFavoriteMovies() async throws {
        userDefaults.removeObject(forKey: favoriteMoviesKey)
    }

    // MARK: - Private Methods

    private func saveMoviesToUserDefaults(_ movies: [Movie]) throws {
        let data = try JSONEncoder().encode(movies)
        userDefaults.set(data, forKey: favoriteMoviesKey)
    }
}
