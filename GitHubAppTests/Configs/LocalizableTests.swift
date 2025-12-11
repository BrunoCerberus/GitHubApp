//
//  LocalizableTests.swift
//  GitHubAppTests
//
//  Created by bruno on localization.
//

@testable import GitHubApp
import Testing

/// Unit tests for the Localizable wrapper struct.
///
/// Consolidated test that verifies all localized strings are properly defined.
@MainActor
struct LocalizableTests {
    // MARK: - Comprehensive Localization Tests

    @Test("All localized strings are properly formatted and not showing keys")
    func allStringsAreProperlyFormatted() {
        let stringsToCheck: [(String, String)] = [
            // Movie Details
            (Localizable.movieDetails.creditsTitle, "movie_details."),
            (Localizable.movieDetails.creditsEmpty, "movie_details."),
            (Localizable.movieDetails.reviewsTitle, "movie_details."),
            (Localizable.movieDetails.reviewsEmpty, "movie_details."),
            (Localizable.movieDetails.loadingDetails, "movie_details."),
            // Favorites
            (Localizable.favorites.title, "favorites."),
            (Localizable.favorites.emptyState, "favorites."),
            // Settings
            (Localizable.settings.title, "settings."),
            (Localizable.settings.profileImage, "settings."),
            (Localizable.settings.profileImageTapToChange, "settings."),
            (Localizable.settings.appVersion, "settings."),
            (Localizable.settings.clearFavoriteMovies, "settings."),
            (Localizable.settings.clearFavoriteMoviesConfirmation, "settings."),
            (Localizable.settings.clearFavoriteMoviesAlertTitle, "settings."),
            (Localizable.settings.clearFavoriteMoviesAlertMessage, "settings."),
            (Localizable.settings.clearFavoriteMoviesAlertClear, "settings."),
            (Localizable.settings.clearFavoriteMoviesAlertCancel, "settings."),
            (Localizable.settings.rateApp, "settings."),
            (Localizable.settings.rateAppMessage, "settings."),
            (Localizable.settings.rateAppButton, "settings."),
            (Localizable.settings.rateAppThanks, "settings."),
            // API Errors
            (Localizable.apiErrors.urlConstructionFailed, "api_error."),
            // Widget
            (Localizable.widget.upcomingMoviesTitle, "widget."),
            (Localizable.widget.upcomingMoviesDescription, "widget."),
            (Localizable.widget.loadingMovies, "widget."),
            // Home
            (Localizable.home.loadingMovies, "home."),
            (Localizable.home.searchMovies, "home."),
        ]

        for (localizedString, keyPrefix) in stringsToCheck {
            #expect(!localizedString.isEmpty, "Localized string should not be empty")
            #expect(!localizedString.hasPrefix(keyPrefix), "String should be localized, not showing the key: \(localizedString)")
        }
    }

    // MARK: - Parameterized String Tests

    @Test("Parameterized strings correctly substitute values")
    func parameterizedStringsWork() {
        let testURL = "https://test.com/api"
        let errorMessage = Localizable.apiErrors.invalidBaseURL(testURL)

        #expect(!errorMessage.isEmpty, "Error message should not be empty")
        #expect(errorMessage.contains(testURL), "Error message should contain the provided URL")
        #expect(!errorMessage.hasPrefix("api_error."), "String should be localized, not showing the key")
    }

    @Test("Parameterized strings handle special characters")
    func parameterizedStringsWithSpecialCharacters() {
        let testURL = "https://test.com/path?param=value&other=123"
        let errorMessage = Localizable.apiErrors.invalidBaseURL(testURL)

        #expect(errorMessage.contains(testURL), "Error message should handle URLs with special characters")
    }
}
