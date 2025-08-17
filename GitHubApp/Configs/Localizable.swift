//
//  Localizable.swift
//  GitHubApp
//
//  Created by bruno on localization.
//

import Foundation

/**
 * Localizable wrapper providing easy access to localized strings.
 *
 * This struct provides a centralized way to access localized strings throughout the app.
 * It uses NSLocalizedString internally and provides type-safe access to all localized content.
 *
 * Example usage:
 * ```swift
 * Text(Localizable.movieDetails.creditsTitle)
 * ```
 */
struct Localizable {
    // MARK: - Private Initializer

    /// Private initializer to prevent instantiation
    private init() {}

    // MARK: - Movie Details

    /// Movie details related localized strings
    struct MovieDetails {
        /// Private initializer to prevent instantiation
        private init() {}

        /// "Credits" section title
        static let creditsTitle = NSLocalizedString("movie_details.credits.title", comment: "Credits section title")

        /// "No credits available" empty state message
        static let creditsEmpty = NSLocalizedString("movie_details.credits.empty", comment: "No credits available message")

        /// "Reviews" section title
        static let reviewsTitle = NSLocalizedString("movie_details.reviews.title", comment: "Reviews section title")

        /// "No reviews available" empty state message
        static let reviewsEmpty = NSLocalizedString("movie_details.reviews.empty", comment: "No reviews available message")
    }

    // MARK: - Liked Movies

    /// Liked movies related localized strings
    struct LikedMovies {
        /// Private initializer to prevent instantiation
        private init() {}

        /// "Liked Movies" title
        static let title = NSLocalizedString("liked_movies.title", comment: "Liked Movies title")

        /// "Your liked movies will appear here." empty state message
        static let emptyState = NSLocalizedString("liked_movies.empty_state", comment: "Empty state message for liked movies")
    }

    // MARK: - API Errors

    /// API error related localized strings
    struct APIErrors {
        /// Private initializer to prevent instantiation
        private init() {}

        /// "Invalid base URL: %@" error message
        /// - Parameter url: The invalid URL string
        /// - Returns: Localized error message with the URL
        static func invalidBaseURL(_ url: String) -> String {
            String(format: NSLocalizedString("api_error.invalid_base_url", comment: "Invalid base URL error"), url)
        }

        /// "Failed to construct URL from components" error message
        static let urlConstructionFailed = NSLocalizedString("api_error.url_construction_failed", comment: "URL construction failed error")
    }

    // MARK: - Convenience Access

    /// Convenience access to movie details strings
    static let movieDetails = MovieDetails.self

    /// Convenience access to liked movies strings
    static let likedMovies = LikedMovies.self

    /// Convenience access to API error strings
    static let apiErrors = APIErrors.self
}
