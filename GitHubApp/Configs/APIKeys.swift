//
//  APIKeys.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Foundation

/**
 * API Keys Provider for secure credential management.
 *
 * This enum provides a centralized way to manage API keys with multiple
 * fallback mechanisms for different deployment scenarios.
 *
 * Security Features:
 * - Primary storage in iOS Keychain for maximum security
 * - Environment variable fallback for CI/CD compatibility
 * - No hardcoded keys in source code
 * - Automatic key persistence for future use
 *
 * Usage:
 * - Keys are automatically retrieved when accessed
 * - Keys are stored securely in the keychain
 * - Supports both development and production environments
 */
enum APIKeysProvider {
    // MARK: - Constants

    /// Keychain service identifier for API keys
    private static let keychainService: String = "com.bruno.GitHubApp.APIKeys"

    /// Key identifier for The Movie Database API key
    private static let movieAPIKeyKey: String = "TheMovieAPIKey"

    // MARK: - Keychain Manager

    /// Shared keychain manager instance for API key storage
    private static let keychainManager: KeychainManager = .init(service: keychainService)

    // MARK: - API Keys

    /**
     * The Movie Database API key with secure fallback mechanisms.
     *
     * Retrieval priority:
     * 1. iOS Keychain (most secure)
     * 2. Environment variable (for CI/CD)
     * 3. Runtime error if no key available
     *
     * The key is automatically stored in keychain for future use
     * regardless of the source.
     */
    static let theMovieAPIKey: String = {
        // First try to retrieve from keychain (most secure)
        if let apiKey = try? keychainManager.retrieve(for: movieAPIKeyKey), !apiKey.isEmpty {
            return apiKey
        }

        // If not in keychain, try environment variable (for CI/CD compatibility)
        if let apiKey = ProcessInfo.processInfo.environment["API_KEY"], !apiKey.isEmpty {
            // Store in keychain for future use
            try? keychainManager.save(apiKey, for: movieAPIKeyKey)
            return apiKey
        }

        // No key available - this should not happen in production
        #if DEBUG
            fatalError("API_KEY environment variable not set. Please set API_KEY environment variable for development.")
        #else
            fatalError("API key not available. Please ensure API_KEY is properly configured.")
        #endif
    }()

    // MARK: - Public Methods

    /**
     * Set the Movie API key in keychain.
     *
     * This method allows runtime updates of the API key,
     * useful for user-provided keys or key rotation.
     *
     * - Parameter apiKey: The API key to store securely
     * - Throws: KeychainError if the operation fails
     */
    static func setMovieAPIKey(_ apiKey: String) throws {
        try keychainManager.save(apiKey, for: movieAPIKeyKey)
    }

    /**
     * Get the Movie API key from keychain.
     *
     * - Returns: The stored API key
     * - Throws: KeychainError if the key is not found or operation fails
     */
    static func getMovieAPIKey() throws -> String {
        try keychainManager.retrieve(for: movieAPIKeyKey)
    }

    /**
     * Check if Movie API key exists in keychain.
     *
     * This is a lightweight check that doesn't retrieve the actual key.
     *
     * - Returns: True if the key exists, false otherwise
     */
    static func hasMovieAPIKey() -> Bool {
        keychainManager.exists(for: movieAPIKeyKey)
    }

    /**
     * Remove the Movie API key from keychain.
     *
     * This method allows clearing the stored key, useful for
     * security purposes or key rotation.
     *
     * - Throws: KeychainError if the operation fails
     */
    static func removeMovieAPIKey() throws {
        try keychainManager.delete(for: movieAPIKeyKey)
    }
}
