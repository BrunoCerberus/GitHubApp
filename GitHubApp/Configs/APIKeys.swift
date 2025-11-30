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

    /// Key identifier for The Movie Database API key (v3 query parameter auth)
    private static let movieAPIKeyKey: String = "TheMovieAPIKey"

    /// Key identifier for The Movie Database Access Token (v3/v4 Bearer auth)
    private static let movieAccessTokenKey: String = "TheMovieAccessToken"

    // MARK: - Keychain Manager

    /// Shared keychain manager instance for API key storage
    private static let keychainManager: KeychainManager = .init(service: keychainService)

    // MARK: - API Keys

    /**
     * The Movie Database API key.
     *
     * The key is read from Secrets.plist file with fallbacks to environment variables and keychain.
     * This provides a clean separation between development and production environments.
     */
    static let theMovieAPIKey: String = {
        // First try to get from Secrets.plist
        if let apiKey = loadAPIKeyFromSecretsPlist(), !apiKey.isEmpty {
            return apiKey
        }

        // Fallback to environment variable (for CI/CD and debugging)
        if let apiKey = ProcessInfo.processInfo.environment["API_KEY"], !apiKey.isEmpty {
            return apiKey
        }

        // Fallback to keychain if environment variable is not set
        do {
            return try getMovieAPIKey()
        } catch {
            // If keychain also fails, crash with a helpful error message
            // This is a critical configuration error that must be fixed before deployment
            fatalError("""
            SECURITY ERROR: API_KEY not found in Secrets.plist, environment variables, or keychain.

            To fix this:
            1. Add API_KEY to Secrets.plist file, OR
            2. Set the API_KEY environment variable in your build configuration, OR
            3. Call APIKeysProvider.setMovieAPIKey("your_api_key") before accessing theMovieAPIKey

            The app cannot function without a valid API key. Providing a hardcoded fallback
            would be a security vulnerability.
            """)
        }
    }()

    /**
     * The Movie Database API Read Access Token.
     *
     * This token is used for Bearer authentication in the Authorization header.
     * It's more secure than query parameter authentication as it:
     * - Doesn't appear in server access logs
     * - Isn't cached in URL history
     * - Follows OWASP security best practices
     *
     * Note: This is different from the API Key. Get your Access Token from:
     * https://www.themoviedb.org/settings/api (under "API Read Access Token")
     */
    static let theMovieAccessToken: String = {
        // Skip token loading during unit tests (mocks are used instead)
        // Check multiple indicators of test environment
        if ProcessInfo.processInfo.environment["IS_RUNNING_UNIT_TESTS"] == "YES" ||
            ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ||
            NSClassFromString("XCTestCase") != nil
        {
            return "test-token-placeholder"
        }

        // First try to get from Secrets.plist
        if let accessToken = loadAccessTokenFromSecretsPlist(), !accessToken.isEmpty {
            return accessToken
        }

        // Fallback to environment variable (for CI/CD and debugging)
        if let accessToken = ProcessInfo.processInfo.environment["TMDB_ACCESS_TOKEN"], !accessToken.isEmpty {
            return accessToken
        }

        // Fallback to keychain if environment variable is not set
        do {
            return try getMovieAccessToken()
        } catch {
            // If keychain also fails, crash with a helpful error message
            fatalError("""
            SECURITY ERROR: TMDB_ACCESS_TOKEN not found in Secrets.plist, environment variables, or keychain.

            To fix this:
            1. Add TMDB_ACCESS_TOKEN to Secrets.plist file, OR
            2. Set the TMDB_ACCESS_TOKEN environment variable in your build configuration, OR
            3. Call APIKeysProvider.setMovieAccessToken("your_token") before accessing theMovieAccessToken

            Get your API Read Access Token from: https://www.themoviedb.org/settings/api

            The app uses Bearer token authentication for enhanced security.
            """)
        }
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

    // MARK: - Access Token Methods

    /**
     * Set the Movie Access Token in keychain.
     *
     * This method allows runtime updates of the access token,
     * useful for user-provided tokens or token rotation.
     *
     * - Parameter accessToken: The access token to store securely
     * - Throws: KeychainError if the operation fails
     */
    static func setMovieAccessToken(_ accessToken: String) throws {
        try keychainManager.save(accessToken, for: movieAccessTokenKey)
    }

    /**
     * Get the Movie Access Token from keychain.
     *
     * - Returns: The stored access token
     * - Throws: KeychainError if the token is not found or operation fails
     */
    static func getMovieAccessToken() throws -> String {
        try keychainManager.retrieve(for: movieAccessTokenKey)
    }

    /**
     * Check if Movie Access Token exists in keychain.
     *
     * This is a lightweight check that doesn't retrieve the actual token.
     *
     * - Returns: True if the token exists, false otherwise
     */
    static func hasMovieAccessToken() -> Bool {
        keychainManager.exists(for: movieAccessTokenKey)
    }

    /**
     * Remove the Movie Access Token from keychain.
     *
     * This method allows clearing the stored token, useful for
     * security purposes or token rotation.
     *
     * - Throws: KeychainError if the operation fails
     */
    static func removeMovieAccessToken() throws {
        try keychainManager.delete(for: movieAccessTokenKey)
    }

    // MARK: - Private Methods

    /**
     * Load API key from Secrets.plist file.
     *
     * - Returns: The API key if found, nil otherwise
     */
    private static func loadAPIKeyFromSecretsPlist() -> String? {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let apiKey = plist["API_KEY"] as? String
        else {
            return nil
        }
        return apiKey
    }

    /**
     * Load Access Token from Secrets.plist file.
     *
     * - Returns: The access token if found, nil otherwise
     */
    private static func loadAccessTokenFromSecretsPlist() -> String? {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let accessToken = plist["TMDB_ACCESS_TOKEN"] as? String
        else {
            return nil
        }
        return accessToken
    }

    // MARK: - Testing Support

    /**
     * Get the Movie API key with fresh evaluation (for testing).
     *
     * This method re-evaluates the fallback hierarchy each time it's called,
     * making it suitable for testing different scenarios.
     *
     * - Returns: The API key from the current fallback hierarchy
     */
    static func getCurrentMovieAPIKey() -> String {
        // First try to get from Secrets.plist
        if let apiKey = loadAPIKeyFromSecretsPlist(), !apiKey.isEmpty {
            return apiKey
        }

        // Fallback to environment variable (for CI/CD and debugging)
        if let apiKey = ProcessInfo.processInfo.environment["API_KEY"], !apiKey.isEmpty {
            return apiKey
        }

        // Fallback to keychain if environment variable is not set
        do {
            return try getMovieAPIKey()
        } catch {
            // If keychain also fails, crash with a helpful error message
            // This is a critical configuration error that must be fixed before deployment
            fatalError("""
            SECURITY ERROR: API_KEY not found in Secrets.plist, environment variables, or keychain.

            To fix this:
            1. Add API_KEY to Secrets.plist file, OR
            2. Set the API_KEY environment variable in your build configuration, OR
            3. Call APIKeysProvider.setMovieAPIKey("your_api_key") before accessing theMovieAPIKey

            The app cannot function without a valid API key. Providing a hardcoded fallback
            would be a security vulnerability.
            """)
        }
    }
}
