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
            Localizable.apiErrors.invalidBaseURL(url)
        case .urlConstructionFailed:
            Localizable.apiErrors.urlConstructionFailed
        }
    }
}

/**
 * Authorization header for API requests.
 *
 * Uses Bearer token authentication instead of query parameter API keys
 * to prevent API key exposure in server logs and URL history.
 *
 * Security Benefits:
 * - API key not logged in server access logs
 * - API key not visible in browser/app history
 * - API key not cached in HTTP intermediaries
 * - Follows OWASP security best practices
 */
struct APIAuthorizationHeader: Codable {
    let authorization: String

    enum CodingKeys: String, CodingKey {
        case authorization = "Authorization"
    }

    init(bearerToken: String) {
        authorization = "Bearer \(bearerToken)"
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
    case fetchMovies(page: Int)

    /// Search for movies by query string
    case searchMovies(query: String, page: Int)

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
     * API Read Access Token for The Movie Database API.
     *
     * Used for Bearer token authentication in the Authorization header.
     * This is more secure than passing the API key in query parameters.
     */
    private var accessToken: String {
        APIKeysProvider.theMovieAccessToken
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
        case let .fetchMovies(page):
            // Endpoint: /movie/upcoming - Get upcoming movies
            components.path += "/movie/upcoming"
            queryItems.append(URLQueryItem(name: "page", value: "\(page)"))

        case let .searchMovies(query, page):
            // Endpoint: /search/movie - Search movies by title
            components.path += "/search/movie"
            queryItems.append(URLQueryItem(name: "query", value: query))
            queryItems.append(URLQueryItem(name: "page", value: "\(page)"))

        case let .fetchCredits(id):
            // Endpoint: /movie/{id}/credits - Get cast and crew
            components.path += "/movie/\(id)/credits"

        case let .fetchReviews(id):
            // Endpoint: /movie/{id}/reviews - Get movie reviews
            components.path += "/movie/\(id)/reviews"
        }

        // Set query items (API key is now passed via Authorization header for security)
        components.queryItems = queryItems.isEmpty ? nil : queryItems

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
     * Uses Bearer token authentication via Authorization header
     * instead of query parameter for enhanced security.
     *
     * Security Note: The Movie Database API supports both query parameter
     * (api_key) and Bearer token authentication. We use Bearer tokens to:
     * - Prevent API key exposure in server access logs
     * - Avoid caching of API keys in HTTP intermediaries
     * - Follow OWASP API security best practices
     */
    var header: Codable? {
        APIAuthorizationHeader(bearerToken: accessToken)
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
