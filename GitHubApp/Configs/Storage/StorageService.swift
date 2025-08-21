//
//  StorageService.swift
//  GitHubApp
//
//  Created by bruno on storage-migration.
//

import Foundation
import SwiftData

/**
 * Protocol defining storage operations for the application.
 *
 * This protocol provides a clean abstraction layer for data persistence,
 * allowing different implementations (SwiftData, UserDefaults, etc.)
 * while maintaining a consistent interface across the application.
 */
protocol StorageServiceProtocol: AnyObject {
    // MARK: - Generic CRUD Operations

    /**
     * Save a single object to storage.
     *
     * - Parameters:
     *   - object: The object to save
     *   - context: Optional context identifier for organization
     * - Throws: StorageError if the operation fails
     */
    func save(_ object: some Codable & Identifiable, context: String?) async throws

    /**
     * Save multiple objects to storage.
     *
     * - Parameters:
     *   - objects: Array of objects to save
     *   - context: Optional context identifier for organization
     * - Throws: StorageError if the operation fails
     */
    func save(_ objects: [some Codable & Identifiable], context: String?) async throws

    /**
     * Fetch objects of a specific type from storage.
     *
     * - Parameters:
     *   - type: The type of objects to fetch
     *   - context: Optional context identifier for filtering
     * - Returns: Array of objects matching the criteria
     * - Throws: StorageError if the operation fails
     */
    func fetch<T: Codable & Identifiable>(_ type: T.Type, context: String?) async throws -> [T]

    /**
     * Fetch a single object by its identifier.
     *
     * - Parameters:
     *   - type: The type of object to fetch
     *   - id: The identifier of the object
     *   - context: Optional context identifier for filtering
     * - Returns: The object if found, nil otherwise
     * - Throws: StorageError if the operation fails
     */
    func fetch<T: Codable & Identifiable>(_ type: T.Type, id: T.ID, context: String?) async throws -> T?

    /**
     * Delete objects from storage.
     *
     * - Parameters:
     *   - objects: Array of objects to delete
     *   - context: Optional context identifier for filtering
     * - Throws: StorageError if the operation fails
     */
    func delete(_ objects: [some Codable & Identifiable], context: String?) async throws

    /**
     * Delete a single object from storage.
     *
     * - Parameters:
     *   - object: The object to delete
     *   - context: Optional context identifier for filtering
     * - Throws: StorageError if the operation fails
     */
    func delete(_ object: some Codable & Identifiable, context: String?) async throws

    /**
     * Delete all objects of a specific type.
     *
     * - Parameters:
     *   - type: The type of objects to delete
     *   - context: Optional context identifier for filtering
     * - Throws: StorageError if the operation fails
     */
    func deleteAll(_ type: (some Codable & Identifiable).Type, context: String?) async throws

    // MARK: - Specialized Movie Operations

    /**
     * Check if a movie is marked as liked.
     *
     * - Parameter movie: The movie to check
     * - Returns: True if the movie is liked, false otherwise
     * - Throws: StorageError if the operation fails
     */
    func isMovieLiked(_ movie: Movie) async throws -> Bool

    /**
     * Toggle the liked status of a movie.
     *
     * - Parameter movie: The movie to toggle
     * - Returns: Updated list of all liked movies
     * - Throws: StorageError if the operation fails
     */
    func toggleMovieLike(_ movie: Movie) async throws -> [Movie]

    /**
     * Fetch all liked movies.
     *
     * - Returns: Array of liked movies
     * - Throws: StorageError if the operation fails
     */
    func fetchLikedMovies() async throws -> [Movie]

    /**
     * Clear all liked movies.
     *
     * - Throws: StorageError if the operation fails
     */
    func clearLikedMovies() async throws
}

/**
 * Errors that can occur during storage operations.
 */
enum StorageError: Error, LocalizedError {
    case saveFailure(String)
    case fetchFailure(String)
    case deleteFailure(String)
    case migrationFailure(String)
    case modelNotFound(String)
    case invalidData(String)

    var errorDescription: String? {
        switch self {
        case let .saveFailure(message):
            "Save operation failed: \(message)"
        case let .fetchFailure(message):
            "Fetch operation failed: \(message)"
        case let .deleteFailure(message):
            "Delete operation failed: \(message)"
        case let .migrationFailure(message):
            "Migration failed: \(message)"
        case let .modelNotFound(message):
            "Model not found: \(message)"
        case let .invalidData(message):
            "Invalid data: \(message)"
        }
    }
}

/**
 * Context identifiers for organizing data in storage.
 */
enum StorageContext {
    static let likedMovies = "liked_movies"
    static let settings = "user_settings"
    static let widget = "widget_data"
}
