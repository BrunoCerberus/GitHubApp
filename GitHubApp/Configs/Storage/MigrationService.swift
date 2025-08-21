//
//  MigrationService.swift
//  GitHubApp
//
//  Created by bruno on storage-migration.
//

import Foundation

/**
 * Service responsible for migrating data from UserDefaults to SwiftData.
 *
 * This service handles the one-time migration of existing user data
 * from the legacy UserDefaults storage to the new SwiftData-based
 * storage system, ensuring data continuity during the transition.
 */
final class MigrationService {
    // MARK: - Properties

    /// UserDefaults instance for reading legacy data
    private let userDefaults: UserDefaults

    /// Migration status tracking
    private let migrationKey = "has_migrated_to_swiftdata"

    // MARK: - Initialization

    /**
     * Initialize the migration service.
     *
     * - Parameter userDefaults: UserDefaults instance to migrate from
     */
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Migration

    /**
     * Perform migration from UserDefaults to SwiftData.
     *
     * This method checks if migration has already been performed
     * and migrates all relevant data if needed.
     *
     * - Parameter storageService: The SwiftData storage service to migrate to
     * - Throws: StorageError if migration fails
     */
    func migrateToSwiftData(storageService: StorageServiceProtocol) async throws {
        // Check if migration has already been performed
        if userDefaults.bool(forKey: migrationKey) {
            return
        }

        print("🔄 Starting migration from UserDefaults to SwiftData...")

        do {
            // Migrate favorite movies
            try await migrateLikedMovies(to: storageService)

            // Migrate user settings
            try await migrateUserSettings(to: storageService)

            // Mark migration as completed
            userDefaults.set(true, forKey: migrationKey)
            userDefaults.synchronize()

            print("✅ Migration completed successfully")
        } catch {
            print("❌ Migration failed: \(error.localizedDescription)")
            throw StorageError.migrationFailure("Migration failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Private Migration Methods

    /**
     * Migrate favorite movies from UserDefaults to SwiftData.
     */
    private func migrateLikedMovies(to storageService: StorageServiceProtocol) async throws {
        let favoriteMoviesKey = "favoriteMoviesKey"

        guard let data = userDefaults.data(forKey: favoriteMoviesKey),
              let movies = try? JSONDecoder().decode([Movie].self, from: data)
        else {
            print("📝 No favorite movies to migrate")
            return
        }

        if movies.isEmpty {
            print("📝 No favorite movies to migrate")
        } else {
            print("📝 Migrating \(movies.count) favorite movies...")
            // Save movies to SwiftData
            try await storageService.save(movies, context: StorageContext.favoriteMovies)
            print("✅ Liked movies migrated successfully")
        }

        // Always clean up UserDefaults when there's valid data (even if empty array)
        userDefaults.removeObject(forKey: favoriteMoviesKey)
    }

    /**
     * Migrate user settings from UserDefaults to SwiftData.
     */
    private func migrateUserSettings(to storageService: StorageServiceProtocol) async throws {
        // Migrate profile image data
        if let profileImageData = userDefaults.data(forKey: "profileImageData") {
            try await migrateProfileImage(profileImageData, to: storageService)
        }

        // Migrate app rating status
        let hasRatedApp = userDefaults.bool(forKey: "hasRatedApp")
        if hasRatedApp {
            try await migrateAppRatingStatus(hasRatedApp, to: storageService)
        }

        print("✅ User settings migrated successfully")
    }

    /**
     * Migrate profile image data.
     */
    private func migrateProfileImage(_ imageData: Data, to storageService: StorageServiceProtocol) async throws {
        // For now, we'll store this as a UserSetting in SwiftData
        // In a real implementation, you might want to create a specific model
        let setting = ProfileImageSetting(imageData: imageData)
        try await storageService.save(setting, context: UserSetting.Category.profile)

        // Clean up UserDefaults
        userDefaults.removeObject(forKey: "profileImageData")

        print("✅ Profile image migrated")
    }

    /**
     * Migrate app rating status.
     */
    private func migrateAppRatingStatus(_ hasRated: Bool, to storageService: StorageServiceProtocol) async throws {
        let setting = AppRatingSetting(hasRated: hasRated)
        try await storageService.save(setting, context: UserSetting.Category.app)

        // Clean up UserDefaults
        userDefaults.removeObject(forKey: "hasRatedApp")

        print("✅ App rating status migrated")
    }
}

// MARK: - Migration Helper Models

/**
 * Temporary model for migrating profile image data.
 */
struct ProfileImageSetting: Codable, Identifiable {
    let id = "profileImage"
    let imageData: Data
    let migratedAt: Date = .init()
}

/**
 * Temporary model for migrating app rating status.
 */
struct AppRatingSetting: Codable, Identifiable {
    let id = "hasRatedApp"
    let hasRated: Bool
    let migratedAt: Date = .init()
}
