//
//  LocalizableTests.swift
//  GitHubAppTests
//
//  Created by bruno on localization.
//

@testable import GitHubApp
import Testing

/**
 * Unit tests for the Localizable wrapper struct.
 *
 * This test class ensures that:
 * - All localized strings are properly defined
 * - Strings are not empty
 * - Parameterized strings work correctly
 * - Localization keys exist in string files
 */
struct LocalizableTests {
    // MARK: - Movie Details Tests

    @Test("Movie details credits title is properly localized")
    func movieDetailsCreditsTitle() {
        let creditsTitle = Localizable.movieDetails.creditsTitle

        #expect(!creditsTitle.isEmpty, "Credits title should not be empty")
        #expect(creditsTitle != "movie_details.credits.title", "String should be localized, not showing the key")
    }

    @Test("Movie details credits empty message is properly localized")
    func movieDetailsCreditsEmpty() {
        let creditsEmpty = Localizable.movieDetails.creditsEmpty

        #expect(!creditsEmpty.isEmpty, "Credits empty message should not be empty")
        #expect(creditsEmpty != "movie_details.credits.empty", "String should be localized, not showing the key")
    }

    @Test("Movie details reviews title is properly localized")
    func movieDetailsReviewsTitle() {
        let reviewsTitle = Localizable.movieDetails.reviewsTitle

        #expect(!reviewsTitle.isEmpty, "Reviews title should not be empty")
        #expect(reviewsTitle != "movie_details.reviews.title", "String should be localized, not showing the key")
    }

    @Test("Movie details reviews empty message is properly localized")
    func movieDetailsReviewsEmpty() {
        let reviewsEmpty = Localizable.movieDetails.reviewsEmpty

        #expect(!reviewsEmpty.isEmpty, "Reviews empty message should not be empty")
        #expect(reviewsEmpty != "movie_details.reviews.empty", "String should be localized, not showing the key")
    }

    // MARK: - Liked Movies Tests

    @Test("Favorite movies title is properly localized")
    func likedMoviesTitle() {
        let title = Localizable.favorites.title

        #expect(!title.isEmpty, "Favorite movies title should not be empty")
        #expect(title != "favorites.title", "String should be localized, not showing the key")
    }

    @Test("Favorite movies empty state message is properly localized")
    func likedMoviesEmptyState() {
        let emptyState = Localizable.favorites.emptyState

        #expect(!emptyState.isEmpty, "Favorite movies empty state should not be empty")
        #expect(emptyState != "favorites.empty_state", "String should be localized, not showing the key")
    }

    // MARK: - API Errors Tests

    @Test("API error for invalid base URL is properly localized with parameter substitution")
    func apiErrorInvalidBaseURL() {
        let testURL = "https://invalid-url.com"
        let errorMessage = Localizable.apiErrors.invalidBaseURL(testURL)

        #expect(!errorMessage.isEmpty, "Invalid base URL error should not be empty")
        #expect(errorMessage.contains(testURL), "Error message should contain the provided URL")
        #expect(errorMessage != "api_error.invalid_base_url", "String should be localized, not showing the key")
    }

    @Test("API error for URL construction failure is properly localized")
    func apiErrorURLConstructionFailed() {
        let errorMessage = Localizable.apiErrors.urlConstructionFailed

        #expect(!errorMessage.isEmpty, "URL construction failed error should not be empty")
        #expect(errorMessage != "api_error.url_construction_failed", "String should be localized, not showing the key")
    }

    // MARK: - Widget Tests

    @Test("Widget upcoming movies title is properly localized")
    func widgetUpcomingMoviesTitle() {
        let title = Localizable.widget.upcomingMoviesTitle

        #expect(!title.isEmpty, "Widget upcoming movies title should not be empty")
        #expect(title != "widget.upcoming_movies.title", "String should be localized, not showing the key")
    }

    @Test("Widget upcoming movies description is properly localized")
    func widgetUpcomingMoviesDescription() {
        let description = Localizable.widget.upcomingMoviesDescription

        #expect(!description.isEmpty, "Widget description should not be empty")
        #expect(description != "widget.upcoming_movies.description", "String should be localized, not showing the key")
    }

    @Test("Widget loading movies message is properly localized")
    func widgetLoadingMovies() {
        let loadingMessage = Localizable.widget.loadingMovies

        #expect(!loadingMessage.isEmpty, "Widget loading message should not be empty")
        #expect(loadingMessage != "widget.loading_movies", "String should be localized, not showing the key")
    }

    // MARK: - Home Tests

    @Test("Home loading movies message is properly localized")
    func homeLoadingMovies() {
        let loadingMessage = Localizable.home.loadingMovies

        #expect(!loadingMessage.isEmpty, "Home loading message should not be empty")
        #expect(loadingMessage != "home.loading_movies", "String should be localized, not showing the key")
    }

    // MARK: - Convenience Access Tests

    @Test("Convenience access to movie details works correctly")
    func movieDetailsConvenience() {
        #expect(Localizable.movieDetails.creditsTitle.count > 0, "Movie details should be accessible")
        #expect(Localizable.movieDetails.creditsTitle == Localizable.movieDetails.creditsTitle, "Convenience access should be consistent")
    }

    @Test("Convenience access to favorite movies works correctly")
    func likedMoviesConvenience() {
        #expect(!Localizable.favorites.title.isEmpty, "Favorite movies title should be accessible")
        #expect(Localizable.favorites.title == Localizable.favorites.title, "Convenience access should be consistent")
    }

    @Test("Convenience access to API errors works correctly")
    func apiErrorsConvenience() {
        #expect(!Localizable.apiErrors.urlConstructionFailed.isEmpty, "API errors should be accessible")
        #expect(Localizable.apiErrors.urlConstructionFailed == Localizable.apiErrors.urlConstructionFailed, "Convenience access should be consistent")
    }

    @Test("Convenience access to widget strings works correctly")
    func widgetConvenience() {
        #expect(!Localizable.widget.upcomingMoviesTitle.isEmpty, "Widget strings should be accessible")
        #expect(Localizable.widget.upcomingMoviesTitle == Localizable.widget.upcomingMoviesTitle, "Convenience access should be consistent")
    }

    @Test("Convenience access to home strings works correctly")
    func homeConvenience() {
        #expect(!Localizable.home.loadingMovies.isEmpty, "Home strings should be accessible")
        #expect(Localizable.home.loadingMovies == Localizable.home.loadingMovies, "Convenience access should be consistent")
    }

    // MARK: - Edge Cases Tests

    @Test("Parameterized strings handle empty parameters gracefully")
    func parameterizedStringsWithEmptyParameter() {
        let errorMessage = Localizable.apiErrors.invalidBaseURL("")

        #expect(!errorMessage.isEmpty, "Error message should not be empty even with empty parameter")
        // The message might contain placeholder or format specifier, that's fine
    }

    @Test("Parameterized strings handle special characters")
    func parameterizedStringsWithSpecialCharacters() {
        let testURL = "https://test.com/path?param=value&other=123"
        let errorMessage = Localizable.apiErrors.invalidBaseURL(testURL)

        #expect(errorMessage.contains(testURL), "Error message should handle URLs with special characters")
    }

    // MARK: - Settings Tests

    @Test("Settings title is properly localized")
    func settingsTitle() {
        let title = Localizable.settings.title

        #expect(!title.isEmpty, "Settings title should not be empty")
        #expect(title != "settings.title", "String should be localized, not showing the key")
    }

    @Test("Settings profile image label is properly localized")
    func settingsProfileImage() {
        let label = Localizable.settings.profileImage

        #expect(!label.isEmpty, "Profile image label should not be empty")
        #expect(label != "settings.profile_image", "String should be localized, not showing the key")
    }

    @Test("Settings profile image tap hint is properly localized")
    func settingsProfileImageTapToChange() {
        let hint = Localizable.settings.profileImageTapToChange

        #expect(!hint.isEmpty, "Profile image hint should not be empty")
        #expect(hint != "settings.profile_image_tap_to_change", "String should be localized, not showing the key")
    }

    @Test("Settings app version label is properly localized")
    func settingsAppVersion() {
        let label = Localizable.settings.appVersion

        #expect(!label.isEmpty, "App version label should not be empty")
        #expect(label != "settings.app_version", "String should be localized, not showing the key")
    }

    @Test("Settings clear favorites button is properly localized")
    func settingsClearFavoriteMovies() {
        let label = Localizable.settings.clearFavoriteMovies

        #expect(!label.isEmpty, "Clear favorites button should not be empty")
        #expect(label != "settings.clear_favorited_movies", "String should be localized, not showing the key")
    }

    @Test("Settings clear favorites confirmation is properly localized")
    func settingsClearFavoriteMoviesConfirmation() {
        let message = Localizable.settings.clearFavoriteMoviesConfirmation

        #expect(!message.isEmpty, "Clear favorites confirmation should not be empty")
        #expect(message != "settings.clear_favorited_movies_confirmation", "String should be localized, not showing the key")
    }

    @Test("Settings clear favorites alert title is properly localized")
    func settingsClearFavoriteMoviesAlertTitle() {
        let title = Localizable.settings.clearFavoriteMoviesAlertTitle

        #expect(!title.isEmpty, "Clear favorites alert title should not be empty")
        #expect(title != "settings.clear_favorited_movies_alert_title", "String should be localized, not showing the key")
    }

    @Test("Settings clear favorites alert message is properly localized")
    func settingsClearFavoriteMoviesAlertMessage() {
        let message = Localizable.settings.clearFavoriteMoviesAlertMessage

        #expect(!message.isEmpty, "Clear favorites alert message should not be empty")
        #expect(message != "settings.clear_favorited_movies_alert_message", "String should be localized, not showing the key")
    }

    @Test("Settings clear favorites alert clear button is properly localized")
    func settingsClearFavoriteMoviesAlertClear() {
        let buttonText = Localizable.settings.clearFavoriteMoviesAlertClear

        #expect(!buttonText.isEmpty, "Clear button should not be empty")
        #expect(buttonText != "settings.clear_favorited_movies_alert_clear", "String should be localized, not showing the key")
    }

    @Test("Settings clear favorites alert cancel button is properly localized")
    func settingsClearFavoriteMoviesAlertCancel() {
        let buttonText = Localizable.settings.clearFavoriteMoviesAlertCancel

        #expect(!buttonText.isEmpty, "Cancel button should not be empty")
        #expect(buttonText != "settings.clear_favorited_movies_alert_cancel", "String should be localized, not showing the key")
    }

    @Test("Settings rate app section title is properly localized")
    func settingsRateApp() {
        let title = Localizable.settings.rateApp

        #expect(!title.isEmpty, "Rate app section title should not be empty")
        #expect(title != "settings.rate_app", "String should be localized, not showing the key")
    }

    @Test("Settings rate app message is properly localized")
    func settingsRateAppMessage() {
        let message = Localizable.settings.rateAppMessage

        #expect(!message.isEmpty, "Rate app message should not be empty")
        #expect(message != "settings.rate_app_message", "String should be localized, not showing the key")
    }

    @Test("Settings rate app button is properly localized")
    func settingsRateAppButton() {
        let buttonText = Localizable.settings.rateAppButton

        #expect(!buttonText.isEmpty, "Rate app button should not be empty")
        #expect(buttonText != "settings.rate_app_button", "String should be localized, not showing the key")
    }

    @Test("Settings rate app thanks message is properly localized")
    func settingsRateAppThanks() {
        let message = Localizable.settings.rateAppThanks

        #expect(!message.isEmpty, "Rate app thanks message should not be empty")
        #expect(message != "settings.rate_app_thanks", "String should be localized, not showing the key")
    }

    @Test("Convenience access to settings works correctly")
    func settingsConvenience() {
        #expect(!Localizable.settings.title.isEmpty, "Settings title should be accessible")
        #expect(Localizable.settings.title == Localizable.settings.title, "Convenience access should be consistent")
    }

    @Test("Movie details loading message is properly localized")
    func movieDetailsLoadingDetails() {
        let loadingMessage = Localizable.movieDetails.loadingDetails

        #expect(!loadingMessage.isEmpty, "Loading message should not be empty")
        #expect(loadingMessage != "movie_details.loading", "String should be localized, not showing the key")
    }

    @Test("Home search prompt is properly localized")
    func homeSearchMovies() {
        let searchPrompt = Localizable.home.searchMovies

        #expect(!searchPrompt.isEmpty, "Search prompt should not be empty")
        #expect(searchPrompt != "home.search_movies", "String should be localized, not showing the key")
    }

    // MARK: - NSLocalizedString Integration Tests

    @Test("All localized strings are properly formatted")
    func allStringsAreProperlyFormatted() {
        let strings = [
            Localizable.movieDetails.creditsTitle,
            Localizable.movieDetails.creditsEmpty,
            Localizable.movieDetails.reviewsTitle,
            Localizable.movieDetails.reviewsEmpty,
            Localizable.movieDetails.loadingDetails,
            Localizable.favorites.title,
            Localizable.favorites.emptyState,
            Localizable.settings.title,
            Localizable.settings.profileImage,
            Localizable.settings.appVersion,
            Localizable.settings.clearFavoriteMovies,
            Localizable.settings.rateApp,
            Localizable.apiErrors.urlConstructionFailed,
            Localizable.widget.upcomingMoviesTitle,
            Localizable.widget.upcomingMoviesDescription,
            Localizable.widget.loadingMovies,
            Localizable.home.loadingMovies,
            Localizable.home.searchMovies,
        ]

        for string in strings {
            #expect(!string.isEmpty, "Localized string should not be empty: \(string)")
            #expect(!(string.hasPrefix("movie_details.") || string.hasPrefix("favorites.") || string.hasPrefix("settings.") || string.hasPrefix("api_error.") || string.hasPrefix("widget.") || string.hasPrefix("home.")),
                    "String should be localized, not showing the key: \(string)")
        }
    }
}
