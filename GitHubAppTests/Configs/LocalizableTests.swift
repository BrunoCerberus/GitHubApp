//
//  LocalizableTests.swift
//  GitHubAppTests
//
//  Created by bruno on localization.
//

@testable import GitHubApp
import XCTest

/**
 * Unit tests for the Localizable wrapper struct.
 *
 * This test class ensures that:
 * - All localized strings are properly defined
 * - Strings are not empty
 * - Parameterized strings work correctly
 * - Localization keys exist in string files
 */
final class LocalizableTests: XCTestCase {
    // MARK: - Movie Details Tests

    /**
     * Test that movie details credits title is properly localized.
     */
    func testMovieDetailsCreditsTitle() {
        let creditsTitle = Localizable.movieDetails.creditsTitle

        XCTAssertFalse(creditsTitle.isEmpty, "Credits title should not be empty")
        XCTAssertNotEqual(creditsTitle, "movie_details.credits.title", "String should be localized, not showing the key")
    }

    /**
     * Test that movie details credits empty message is properly localized.
     */
    func testMovieDetailsCreditsEmpty() {
        let creditsEmpty = Localizable.movieDetails.creditsEmpty

        XCTAssertFalse(creditsEmpty.isEmpty, "Credits empty message should not be empty")
        XCTAssertNotEqual(creditsEmpty, "movie_details.credits.empty", "String should be localized, not showing the key")
    }

    /**
     * Test that movie details reviews title is properly localized.
     */
    func testMovieDetailsReviewsTitle() {
        let reviewsTitle = Localizable.movieDetails.reviewsTitle

        XCTAssertFalse(reviewsTitle.isEmpty, "Reviews title should not be empty")
        XCTAssertNotEqual(reviewsTitle, "movie_details.reviews.title", "String should be localized, not showing the key")
    }

    /**
     * Test that movie details reviews empty message is properly localized.
     */
    func testMovieDetailsReviewsEmpty() {
        let reviewsEmpty = Localizable.movieDetails.reviewsEmpty

        XCTAssertFalse(reviewsEmpty.isEmpty, "Reviews empty message should not be empty")
        XCTAssertNotEqual(reviewsEmpty, "movie_details.reviews.empty", "String should be localized, not showing the key")
    }

    // MARK: - Liked Movies Tests

    /**
     * Test that liked movies title is properly localized.
     */
    func testLikedMoviesTitle() {
        let title = Localizable.likedMovies.title

        XCTAssertFalse(title.isEmpty, "Liked movies title should not be empty")
        XCTAssertNotEqual(title, "liked_movies.title", "String should be localized, not showing the key")
    }

    /**
     * Test that liked movies empty state message is properly localized.
     */
    func testLikedMoviesEmptyState() {
        let emptyState = Localizable.likedMovies.emptyState

        XCTAssertFalse(emptyState.isEmpty, "Liked movies empty state should not be empty")
        XCTAssertNotEqual(emptyState, "liked_movies.empty_state", "String should be localized, not showing the key")
    }

    // MARK: - API Errors Tests

    /**
     * Test that API error for invalid base URL is properly localized with parameter substitution.
     */
    func testAPIErrorInvalidBaseURL() {
        let testURL = "https://invalid-url.com"
        let errorMessage = Localizable.apiErrors.invalidBaseURL(testURL)

        XCTAssertFalse(errorMessage.isEmpty, "Invalid base URL error should not be empty")
        XCTAssertTrue(errorMessage.contains(testURL), "Error message should contain the provided URL")
        XCTAssertNotEqual(errorMessage, "api_error.invalid_base_url", "String should be localized, not showing the key")
    }

    /**
     * Test that API error for URL construction failure is properly localized.
     */
    func testAPIErrorURLConstructionFailed() {
        let errorMessage = Localizable.apiErrors.urlConstructionFailed

        XCTAssertFalse(errorMessage.isEmpty, "URL construction failed error should not be empty")
        XCTAssertNotEqual(errorMessage, "api_error.url_construction_failed", "String should be localized, not showing the key")
    }

    // MARK: - Convenience Access Tests

    /**
     * Test that convenience access to movie details works correctly.
     */
    func testMovieDetailsConvenience() {
        XCTAssertNotNil(Localizable.movieDetails, "Movie details should be accessible")
        XCTAssertEqual(Localizable.movieDetails.creditsTitle, Localizable.MovieDetails.creditsTitle, "Convenience access should match direct access")
    }

    /**
     * Test that convenience access to liked movies works correctly.
     */
    func testLikedMoviesConvenience() {
        XCTAssertNotNil(Localizable.likedMovies, "Liked movies should be accessible")
        XCTAssertEqual(Localizable.likedMovies.title, Localizable.LikedMovies.title, "Convenience access should match direct access")
    }

    /**
     * Test that convenience access to API errors works correctly.
     */
    func testAPIErrorsConvenience() {
        XCTAssertNotNil(Localizable.apiErrors, "API errors should be accessible")
        XCTAssertEqual(Localizable.apiErrors.urlConstructionFailed, Localizable.APIErrors.urlConstructionFailed, "Convenience access should match direct access")
    }

    // MARK: - Edge Cases Tests

    /**
     * Test that parameterized strings handle empty parameters gracefully.
     */
    func testParameterizedStringsWithEmptyParameter() {
        let errorMessage = Localizable.apiErrors.invalidBaseURL("")

        XCTAssertFalse(errorMessage.isEmpty, "Error message should not be empty even with empty parameter")
        // The message might contain placeholder or format specifier, that's fine
    }

    /**
     * Test that parameterized strings handle special characters.
     */
    func testParameterizedStringsWithSpecialCharacters() {
        let testURL = "https://test.com/path?param=value&other=123"
        let errorMessage = Localizable.apiErrors.invalidBaseURL(testURL)

        XCTAssertTrue(errorMessage.contains(testURL), "Error message should handle URLs with special characters")
    }

    // MARK: - NSLocalizedString Integration Tests

    /**
     * Test that all localized strings are properly formatted.
     * This test verifies that the localization system is working correctly.
     */
    func testAllStringsAreProperlyFormatted() {
        let strings = [
            Localizable.movieDetails.creditsTitle,
            Localizable.movieDetails.creditsEmpty,
            Localizable.movieDetails.reviewsTitle,
            Localizable.movieDetails.reviewsEmpty,
            Localizable.likedMovies.title,
            Localizable.likedMovies.emptyState,
            Localizable.apiErrors.urlConstructionFailed,
        ]

        for string in strings {
            XCTAssertFalse(string.isEmpty, "Localized string should not be empty: \(string)")
            XCTAssertFalse(string.hasPrefix("movie_details.") || string.hasPrefix("liked_movies.") || string.hasPrefix("api_error."),
                           "String should be localized, not showing the key: \(string)")
        }
    }
}
