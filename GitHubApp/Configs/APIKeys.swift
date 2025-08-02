//
//  APIKeys.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Foundation

enum APIKeysProvider {
    
    // MARK: - Constants
    
    private static let keychainService = "com.bruno.GitHubApp.APIKeys"
    private static let movieAPIKeyKey = "TheMovieAPIKey"
    
    // MARK: - Keychain Manager
    
    private static let keychainManager = KeychainManager(service: keychainService)
    
    // MARK: - API Keys
    
    static let theMovieAPIKey: String = {
        // First try to retrieve from keychain
        if let apiKey = try? keychainManager.retrieve(for: movieAPIKeyKey), !apiKey.isEmpty {
            return apiKey
        }
        
        // If not in keychain, try environment variable (for backward compatibility)
        if let apiKey = ProcessInfo.processInfo.environment["API_KEY"], !apiKey.isEmpty {
            // Store in keychain for future use
            try? keychainManager.save(apiKey, for: movieAPIKeyKey)
            return apiKey
        }
        
        // Fallback to default key (should be replaced with actual key)
        let defaultKey = "da9bc8815fb0fc31d5ef6b3da097a009"
        
        // Store the default key in keychain
        try? keychainManager.save(defaultKey, for: movieAPIKeyKey)
        
        return defaultKey
    }()
    
    // MARK: - Public Methods
    
    /// Set the Movie API key in keychain
    /// - Parameter apiKey: The API key to store
    static func setMovieAPIKey(_ apiKey: String) throws {
        try keychainManager.save(apiKey, for: movieAPIKeyKey)
    }
    
    /// Get the Movie API key from keychain
    /// - Returns: The stored API key
    static func getMovieAPIKey() throws -> String {
        return try keychainManager.retrieve(for: movieAPIKeyKey)
    }
    
    /// Check if Movie API key exists in keychain
    /// - Returns: True if the key exists
    static func hasMovieAPIKey() -> Bool {
        return keychainManager.exists(for: movieAPIKeyKey)
    }
    
    /// Remove the Movie API key from keychain
    static func removeMovieAPIKey() throws {
        try keychainManager.delete(for: movieAPIKeyKey)
    }
}
