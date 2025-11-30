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

        /// "Loading details..." loading state message
        static let loadingDetails = NSLocalizedString("movie_details.loading", comment: "Loading movie details message")

        /// "Credits" section title
        static let creditsTitle = NSLocalizedString("movie_details.credits.title", comment: "Credits section title")

        /// "No credits available" empty state message
        static let creditsEmpty = NSLocalizedString(
            "movie_details.credits.empty",
            comment: "No credits available message"
        )

        /// "Reviews" section title
        static let reviewsTitle = NSLocalizedString("movie_details.reviews.title", comment: "Reviews section title")

        /// "No reviews available" empty state message
        static let reviewsEmpty = NSLocalizedString(
            "movie_details.reviews.empty",
            comment: "No reviews available message"
        )
    }

    // MARK: - Favorites

    /// Favorites related localized strings
    struct Favorites {
        /// Private initializer to prevent instantiation
        private init() {}

        /// "Favorites" title
        static let title = NSLocalizedString("favorites.title", comment: "Favorites title")

        /// "Your favorite movies will appear here." empty state message
        static let emptyState = NSLocalizedString(
            "favorites.empty_state",
            comment: "Empty state message for favorite movies"
        )
    }

    // MARK: - Settings

    /// Settings related localized strings
    struct Settings {
        /// Private initializer to prevent instantiation
        private init() {}

        /// "Settings" title
        static let title = NSLocalizedString("settings.title", comment: "Settings title")

        /// "Profile Image" label
        static let profileImage = NSLocalizedString("settings.profile_image", comment: "Profile Image label")

        /// "Tap to change profile image" hint
        static let profileImageTapToChange = NSLocalizedString(
            "settings.profile_image_tap_to_change",
            comment: "Tap to change profile image hint"
        )

        /// "App Version" label
        static let appVersion = NSLocalizedString("settings.app_version", comment: "App Version label")

        /// "Clear Favorites" button
        static let clearFavoriteMovies = NSLocalizedString(
            "settings.clear_favorited_movies",
            comment: "Clear Favorites button"
        )

        /// "Clear Favorites" confirmation message
        static let clearFavoriteMoviesConfirmation = NSLocalizedString(
            "settings.clear_favorited_movies_confirmation",
            comment: "Clear Favorites confirmation message"
        )

        /// "Clear Favorites" alert title
        static let clearFavoriteMoviesAlertTitle = NSLocalizedString(
            "settings.clear_favorited_movies_alert_title",
            comment: "Clear Favorites alert title"
        )

        /// "Clear Favorites" alert message
        static let clearFavoriteMoviesAlertMessage = NSLocalizedString(
            "settings.clear_favorited_movies_alert_message",
            comment: "Clear Favorites alert message"
        )

        /// "Clear All" button
        static let clearFavoriteMoviesAlertClear = NSLocalizedString(
            "settings.clear_favorited_movies_alert_clear",
            comment: "Clear All button"
        )

        /// "Cancel" button
        static let clearFavoriteMoviesAlertCancel = NSLocalizedString(
            "settings.clear_favorited_movies_alert_cancel",
            comment: "Cancel button"
        )

        /// "Rate App" section title
        static let rateApp = NSLocalizedString("settings.rate_app", comment: "Rate App section title")

        /// "Rate App" message
        static let rateAppMessage = NSLocalizedString("settings.rate_app_message", comment: "Rate App message")

        /// "Rate on App Store" button
        static let rateAppButton = NSLocalizedString("settings.rate_app_button", comment: "Rate on App Store button")

        /// "Thanks for rating!" message
        static let rateAppThanks = NSLocalizedString("settings.rate_app_thanks", comment: "Thanks for rating message")
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
        static let urlConstructionFailed = NSLocalizedString(
            "api_error.url_construction_failed",
            comment: "URL construction failed error"
        )
    }

    // MARK: - Widget

    /// Widget related localized strings
    struct Widget {
        /// Private initializer to prevent instantiation
        private init() {}

        /// "Upcoming Movies" widget title
        static let upcomingMoviesTitle = NSLocalizedString(
            "widget.upcoming_movies.title",
            comment: "Upcoming Movies widget title"
        )

        /// "Shows upcoming movies from The Movie Database" widget description
        static let upcomingMoviesDescription = NSLocalizedString(
            "widget.upcoming_movies.description",
            comment: "Widget description"
        )

        /// "Loading movies..." loading state message
        static let loadingMovies = NSLocalizedString("widget.loading_movies", comment: "Loading movies message")
    }

    // MARK: - Home

    /// Home screen related localized strings
    struct Home {
        /// Private initializer to prevent instantiation
        private init() {}

        /// "Loading movies..." loading state message
        static let loadingMovies = NSLocalizedString("home.loading_movies", comment: "Loading movies message")

        /// "Search movies..." search prompt
        static let searchMovies = NSLocalizedString("home.search_movies", comment: "Search movies prompt")
    }

    // MARK: - Paywall

    /// Paywall related localized strings
    struct Paywall {
        /// Private initializer to prevent instantiation
        private init() {}

        /// "Loading..." loading state message
        static let loading = NSLocalizedString("paywall.loading", comment: "Loading paywall message")

        /// "Unlock Premium" title
        static let title = NSLocalizedString("paywall.title", comment: "Paywall title")

        /// Subtitle describing premium benefits
        static let subtitle = NSLocalizedString("paywall.subtitle", comment: "Paywall subtitle")

        /// First feature title
        static let feature1Title = NSLocalizedString("paywall.feature1.title", comment: "Feature 1 title")

        /// First feature description
        static let feature1Description = NSLocalizedString(
            "paywall.feature1.description",
            comment: "Feature 1 description"
        )

        /// Second feature title
        static let feature2Title = NSLocalizedString("paywall.feature2.title", comment: "Feature 2 title")

        /// Second feature description
        static let feature2Description = NSLocalizedString(
            "paywall.feature2.description",
            comment: "Feature 2 description"
        )

        /// Third feature title
        static let feature3Title = NSLocalizedString("paywall.feature3.title", comment: "Feature 3 title")

        /// Third feature description
        static let feature3Description = NSLocalizedString(
            "paywall.feature3.description",
            comment: "Feature 3 description"
        )

        /// "Error" title for error state
        static let errorTitle = NSLocalizedString("paywall.error.title", comment: "Paywall error title")

        /// "Retry" button text
        static let retry = NSLocalizedString("paywall.retry", comment: "Retry button text")

        /// "Restore Purchases" button text
        static let restorePurchases = NSLocalizedString(
            "paywall.restore_purchases",
            comment: "Restore purchases button"
        )

        /// "Go Premium" settings entry point title
        static let goPremium = NSLocalizedString("paywall.go_premium", comment: "Go premium button")

        /// "Unlock all features" settings entry point description
        static let unlockFeatures = NSLocalizedString(
            "paywall.unlock_features",
            comment: "Unlock features description"
        )

        /// "Premium Active" status for subscribed users
        static let premiumActive = NSLocalizedString("paywall.premium_active", comment: "Premium active status")

        /// "You have full access" description for subscribed users
        static let fullAccess = NSLocalizedString("paywall.full_access", comment: "Full access description")
    }

    // MARK: - Convenience Access

    /// Convenience access to movie details strings
    static let movieDetails = MovieDetails.self

    /// Convenience access to favorite movies strings
    static let favorites = Favorites.self

    /// Convenience access to settings strings
    static let settings = Settings.self

    /// Convenience access to API error strings
    static let apiErrors = APIErrors.self

    /// Convenience access to widget strings
    static let widget = Widget.self

    /// Convenience access to home strings
    static let home = Home.self

    /// Convenience access to paywall strings
    static let paywall = Paywall.self
}
