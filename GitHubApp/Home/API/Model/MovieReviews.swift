//
//  MovieReviews.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Foundation

// MARK: - Reviews

/**
 * Response model for movie reviews API calls.
 *
 * This structure represents the response format from The Movie Database API
 * when fetching user reviews and critic reviews for a specific movie.
 */
struct MovieReviewsResponse: Codable {
    /// Array of review objects returned by the API
    let results: [MovieReview]
}

/**
 * Model representing a single movie review.
 *
 * This model includes review content and author information,
 * with computed properties for safe display formatting.
 *
 * Conforms to:
 * - Identifiable: For SwiftUI list identification
 * - Equatable: For comparison operations
 * - Codable: For JSON serialization/deserialization
 */
struct MovieReview: Identifiable, Equatable, Codable {
    /// Unique review identifier from The Movie Database
    let id: String

    /// Name of the review author
    let author: String

    /// Review content/text
    let content: String

    /**
     * Computed property for display-safe author name.
     *
     * Provides a fallback author name for reviews that don't have a proper author,
     * ensuring the UI always has something to display.
     *
     * - Returns: Author name or "Anonymous" if author is empty
     */
    var displayAuthor: String {
        author.isEmpty ? "Anonymous" : author
    }

    /**
     * Computed property for display-safe review content.
     *
     * Provides a fallback content for reviews that don't have proper content,
     * ensuring the UI always has something to display.
     *
     * - Returns: Review content or "No review content available" if content is empty
     */
    var displayContent: String {
        content.isEmpty ? "No review content available" : content
    }
}
