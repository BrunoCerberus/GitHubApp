//
//  Movie.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import EntropyCore
import Foundation

// MARK: - Movies

/**
 * Response model for movie list API calls.
 *
 * This structure represents the standard response format from The Movie Database API
 * when fetching lists of movies (e.g., upcoming movies, search results).
 */
struct MoviesResponse: Codable {
    /// Array of movie objects returned by the API
    let results: [Movie]
}

/**
 * Movie model representing a single movie from The Movie Database API.
 *
 * This model includes all essential movie information and provides
 * computed properties for display formatting and URL generation.
 *
 * Conforms to:
 * - Codable: For JSON serialization/deserialization
 * - Hashable: For use in collections and sets
 * - Identifiable: For SwiftUI list identification
 */
struct Movie: Codable, Hashable, Identifiable {
    /// Unique movie identifier from The Movie Database
    let id: Int

    /// Movie title
    let title: String

    /// Movie plot summary/description
    let overview: String

    /// Poster image path (relative to base image URL)
    let posterPath: String?

    /**
     * Computed property that generates the full poster image URL.
     *
     * Combines the base image URL with the poster path to create
     * a complete, accessible image URL for display.
     *
     * - Returns: Full poster image URL, or nil if poster path is empty/missing
     */
    var posterURL: URL? {
        guard let posterPath, !posterPath.isEmpty else { return nil }
        return URL(string: BaseURLs.image.rawValue + posterPath)
    }

    /**
     * Computed property for display-safe movie title.
     *
     * Provides a fallback title for movies that don't have a proper title,
     * ensuring the UI always has something to display.
     *
     * - Returns: Movie title or "Untitled" if title is empty
     */
    var displayTitle: String {
        title.isEmpty ? "Untitled" : title
    }

    /**
     * Computed property for display-safe movie overview.
     *
     * Provides a fallback description for movies that don't have an overview,
     * ensuring the UI always has something to display.
     *
     * - Returns: Movie overview or "No overview available" if overview is empty
     */
    var displayOverview: String {
        overview.isEmpty ? "No overview available" : overview
    }
}
