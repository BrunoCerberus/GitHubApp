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

    // MARK: - NSLocalizedString Integration Tests

    @Test("All localized strings are properly formatted")
    func allStringsAreProperlyFormatted() {
        let strings = [
            Localizable.movieDetails.creditsTitle,
            Localizable.movieDetails.creditsEmpty,
            Localizable.movieDetails.reviewsTitle,
            Localizable.movieDetails.reviewsEmpty,
            Localizable.favorites.title,
            Localizable.favorites.emptyState,
            Localizable.apiErrors.urlConstructionFailed,
            Localizable.widget.upcomingMoviesTitle,
            Localizable.widget.upcomingMoviesDescription,
            Localizable.widget.loadingMovies,
            Localizable.home.loadingMovies,
        ]

        for string in strings {
            #expect(!string.isEmpty, "Localized string should not be empty: \(string)")
            #expect(!(string.hasPrefix("movie_details.") || string.hasPrefix("favorites.") || string.hasPrefix("api_error.") || string.hasPrefix("widget.") || string.hasPrefix("home.")),
                    "String should be localized, not showing the key: \(string)")
        }
    }
}
