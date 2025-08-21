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
            return try SwiftDataStorageService(container: container)
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
    }

    let type: StorageType
    let isInMemory: Bool

    /// Production configuration with persistent SwiftData storage
    static let production = StorageConfiguration(
        type: .swiftData,
        isInMemory: false
    )

    /// Testing configuration with in-memory storage
    static let testing = StorageConfiguration(
        type: .swiftData,
        isInMemory: true
    )
}
