//
//  SearchAPI.swift
//  GitHubApp
//
//  Created by Claude Code
//

import EntropyCore
import Foundation

/**
 * API endpoints for the Search module.
 *
 * This enum defines all the API endpoints used by the Search module,
 * specifically for searching movies in The Movie Database.
 *
 * Features:
 * - Automatic API key injection
 * - URL construction with proper query parameters
 * - Debug logging in development builds
 * - Type-safe endpoint definitions
 *
 * Conforms to APIFetcher protocol for network requests.
 */
enum SearchAPI: APIFetcher {
    /// Search for movies by query string
    case searchMovies(query: String, page: Int)

    /**
     * Base URL for The Movie Database API.
     *
     * This is the foundation URL that all endpoints build upon.
     */
    private var baseURL: String {
        BaseURLs.theMovie.rawValue
    }

    /**
     * API key for The Movie Database API.
     *
     * Automatically retrieves the secure API key from the keychain.
     */
    private var apiKey: String {
        APIKeysProvider.theMovieAPIKey
    }

    /**
     * Constructs the complete URL for the API endpoint.
     *
     * This method builds the full URL including:
     * - Base URL from configuration
     * - Endpoint-specific path
     * - Query parameters (search terms, API key, pagination)
     *
     * - Returns: Complete URL string for the API request
     */
    var path: String {
        guard var components = URLComponents(string: baseURL) else {
            fatalError("Invalid base URL: \(baseURL)")
        }

        var queryItems: [URLQueryItem] = []

        switch self {
        case let .searchMovies(query, page):
            // Endpoint: /search/movie - Search movies by title
            components.path += "/search/movie"
            queryItems.append(URLQueryItem(name: "query", value: query))
            queryItems.append(URLQueryItem(name: "page", value: "\(page)"))
        }

        // Add API key to all requests for authentication
        queryItems.append(URLQueryItem(name: "api_key", value: apiKey))
        components.queryItems = queryItems

        guard let urlString = components.string else {
            fatalError("Failed to construct URL from components")
        }

        return urlString
    }

    /**
     * HTTP method for all API requests.
     *
     * All endpoints use GET requests as they are read-only operations.
     */
    var method: HTTPMethod {
        .GET
    }

    /**
     * Request body for API calls.
     *
     * All endpoints are GET requests, so no body is needed.
     */
    var task: Codable? {
        nil
    }

    /**
     * Custom headers for API requests.
     *
     * No custom headers are required for The Movie Database API.
     */
    var header: Codable? {
        nil
    }

    /**
     * Debug logging configuration.
     *
     * Enables debug logging in development builds for easier debugging.
     */
    var debug: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }
}
