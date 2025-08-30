//
//  SharedMovieMainAppTests.swift
//  GitHubAppTests
//

import Foundation
@testable import GitHubApp
import Testing

struct SharedMovieMainAppTests {
    private func createTestMovies() -> (SharedMovie, SharedMovie, SharedMovie, SharedMovie, SharedMovie) {
        let movieWithPoster = SharedMovie(
            id: 1,
            title: "Test Movie",
            overview: "This is a test movie overview",
            posterPath: "/test-poster.jpg"
        )

        let movieWithoutPoster = SharedMovie(
            id: 2,
            title: "Movie Without Poster",
            overview: "This movie has no poster",
            posterPath: nil
        )

        let movieWithEmptyPoster = SharedMovie(
            id: 3,
            title: "Movie With Empty Poster",
            overview: "This movie has empty poster path",
            posterPath: ""
        )

        let movieWithEmptyTitle = SharedMovie(
            id: 4,
            title: "",
            overview: "Movie with empty title",
            posterPath: "/poster.jpg"
        )

        let movieWithEmptyOverview = SharedMovie(
            id: 5,
            title: "Movie With Empty Overview",
            overview: "",
            posterPath: "/poster.jpg"
        )

        return (movieWithPoster, movieWithoutPoster, movieWithEmptyPoster, movieWithEmptyTitle, movieWithEmptyOverview)
    }

    // MARK: - Poster URL Tests

    @Test("Poster URL with valid poster path")
    func posterURLWithValidPosterPath() {
        // Given
        let (movieWithPoster, _, _, _, _) = createTestMovies()

        // When
        let posterURL = movieWithPoster.posterURL

        // Then
        #expect(posterURL != nil)
        #expect(posterURL?.absoluteString == "https://image.tmdb.org/t/p/w500/test-poster.jpg")
    }

    @Test("Poster URL with nil poster path")
    func posterURLWithNilPosterPath() {
        // Given
        let (_, movieWithoutPoster, _, _, _) = createTestMovies()

        // When
        let posterURL = movieWithoutPoster.posterURL

        // Then
        #expect(posterURL == nil)
    }

    @Test("Poster URL with empty poster path")
    func posterURLWithEmptyPosterPath() {
        // Given
        let (_, _, movieWithEmptyPoster, _, _) = createTestMovies()

        // When
        let posterURL = movieWithEmptyPoster.posterURL

        // Then
        #expect(posterURL == nil)
    }

    // MARK: - Display Title Tests

    @Test("Display title with valid title")
    func displayTitleWithValidTitle() {
        // Given
        let (movieWithPoster, _, _, _, _) = createTestMovies()

        // When
        let displayTitle = movieWithPoster.displayTitle

        // Then
        #expect(displayTitle == "Test Movie")
    }

    @Test("Display title with empty title")
    func displayTitleWithEmptyTitle() {
        // Given
        let (_, _, _, movieWithEmptyTitle, _) = createTestMovies()

        // When
        let displayTitle = movieWithEmptyTitle.displayTitle

        // Then
        #expect(displayTitle == "Untitled")
    }

    // MARK: - Display Overview Tests

    @Test("Display overview with valid overview")
    func displayOverviewWithValidOverview() {
        // Given
        let (movieWithPoster, _, _, _, _) = createTestMovies()

        // When
        let displayOverview = movieWithPoster.displayOverview

        // Then
        #expect(displayOverview == "This is a test movie overview")
    }

    @Test("Display overview with empty overview")
    func displayOverviewWithEmptyOverview() {
        // Given
        let (_, _, _, _, movieWithEmptyOverview) = createTestMovies()

        // When
        let displayOverview = movieWithEmptyOverview.displayOverview

        // Then
        #expect(displayOverview == "No overview available")
    }

    // MARK: - Codable Tests

    @Test("Shared movie encoding and decoding")
    func sharedMovieEncodingAndDecoding() throws {
        // Given
        let movie = SharedMovie(
            id: 999,
            title: "Codable Test",
            overview: "Testing encoding and decoding",
            posterPath: "/codable-test.jpg"
        )

        // When
        let encodedData = try JSONEncoder().encode(movie)
        let decodedMovie = try JSONDecoder().decode(SharedMovie.self, from: encodedData)

        // Then
        #expect(decodedMovie.id == movie.id)
        #expect(decodedMovie.title == movie.title)
        #expect(decodedMovie.overview == movie.overview)
        #expect(decodedMovie.posterPath == movie.posterPath)
    }
}
