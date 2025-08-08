//
//  HomeAPI.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import EntropyCore
import Foundation

/**
 * Custom error types for API operations.
 */
enum APIError: Error, LocalizedError {
    case invalidBaseURL(String)
    case urlConstructionFailed

    var errorDescription: String? {
        switch self {
        case let .invalidBaseURL(url):
            "Invalid base URL: \(url)"
        case .urlConstructionFailed:
            "Failed to construct URL from components"
        }
    }
}

/**
 * API endpoints for the Home module.
 *
 * This enum defines all the API endpoints used by the Home module,
 * including movie fetching, searching, and detail retrieval.
 *
 * Features:
 * - Automatic API key injection
 * - URL construction with proper query parameters
 * - Debug logging in development builds
 * - Type-safe endpoint definitions
 *
 * Conforms to APIFetcher protocol for network requests.
 */
enum HomeAPI: APIFetcher {
    /// Fetch upcoming movies from The Movie Database
    case fetchMovies

    /// Search for movies by query string
    case searchMovies(String)

    /// Fetch cast and crew credits for a specific movie
    case fetchCredits(Int)

    /// Fetch reviews for a specific movie
    case fetchReviews(Int)

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
     * - Query parameters (search terms, API key)
     *
     * - Returns: Complete URL string for the API request
     * - Throws: APIError if URL construction fails
     */
    var path: String {
        guard var components = URLComponents(string: baseURL) else {
            fatalError("Invalid base URL: \(baseURL)")
        }

        var queryItems: [URLQueryItem] = []

        switch self {
        case .fetchMovies:
            // Endpoint: /movie/upcoming - Get upcoming movies
            components.path += "/movie/upcoming"

        case let .searchMovies(query):
            // Endpoint: /search/movie - Search movies by title
            components.path += "/search/movie"
            queryItems.append(URLQueryItem(name: "query", value: query))

        case let .fetchCredits(id):
            // Endpoint: /movie/{id}/credits - Get cast and crew
            components.path += "/movie/\(id)/credits"

        case let .fetchReviews(id):
            // Endpoint: /movie/{id}/reviews - Get movie reviews
            components.path += "/movie/\(id)/reviews"
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
