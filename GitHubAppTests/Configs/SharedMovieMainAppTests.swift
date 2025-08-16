//
//  SharedMovieMainAppTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import XCTest

final class SharedMovieMainAppTests: XCTestCase {
    // MARK: - Properties

    private var movieWithPoster: SharedMovie!
    private var movieWithoutPoster: SharedMovie!
    private var movieWithEmptyPoster: SharedMovie!
    private var movieWithEmptyTitle: SharedMovie!
    private var movieWithEmptyOverview: SharedMovie!

    // MARK: - Setup and Teardown

    override func setUp() {
        super.setUp()

        movieWithPoster = SharedMovie(
            id: 1,
            title: "Test Movie",
            overview: "This is a test movie overview",
            posterPath: "/test-poster.jpg"
        )

        movieWithoutPoster = SharedMovie(
            id: 2,
            title: "Movie Without Poster",
            overview: "This movie has no poster",
            posterPath: nil
        )

        movieWithEmptyPoster = SharedMovie(
            id: 3,
            title: "Movie With Empty Poster",
            overview: "This movie has empty poster path",
            posterPath: ""
        )

        movieWithEmptyTitle = SharedMovie(
            id: 4,
            title: "",
            overview: "Movie with empty title",
            posterPath: "/poster.jpg"
        )

        movieWithEmptyOverview = SharedMovie(
            id: 5,
            title: "Movie With Empty Overview",
            overview: "",
            posterPath: "/poster.jpg"
        )
    }

    override func tearDown() {
        movieWithPoster = nil
        movieWithoutPoster = nil
        movieWithEmptyPoster = nil
        movieWithEmptyTitle = nil
        movieWithEmptyOverview = nil
        super.tearDown()
    }

    // MARK: - Poster URL Tests

    func testPosterURLWithValidPosterPath() {
        // When
        let posterURL = movieWithPoster.posterURL

        // Then
        XCTAssertNotNil(posterURL)
        XCTAssertEqual(posterURL?.absoluteString, "https://image.tmdb.org/t/p/w500/test-poster.jpg")
    }

    func testPosterURLWithNilPosterPath() {
        // When
        let posterURL = movieWithoutPoster.posterURL

        // Then
        XCTAssertNil(posterURL)
    }

    func testPosterURLWithEmptyPosterPath() {
        // When
        let posterURL = movieWithEmptyPoster.posterURL

        // Then
        XCTAssertNil(posterURL)
    }

    // MARK: - Display Title Tests

    func testDisplayTitleWithValidTitle() {
        // When
        let displayTitle = movieWithPoster.displayTitle

        // Then
        XCTAssertEqual(displayTitle, "Test Movie")
    }

    func testDisplayTitleWithEmptyTitle() {
        // When
        let displayTitle = movieWithEmptyTitle.displayTitle

        // Then
        XCTAssertEqual(displayTitle, "Untitled")
    }

    // MARK: - Display Overview Tests

    func testDisplayOverviewWithValidOverview() {
        // When
        let displayOverview = movieWithPoster.displayOverview

        // Then
        XCTAssertEqual(displayOverview, "This is a test movie overview")
    }

    func testDisplayOverviewWithEmptyOverview() {
        // When
        let displayOverview = movieWithEmptyOverview.displayOverview

        // Then
        XCTAssertEqual(displayOverview, "No overview available")
    }

    // MARK: - Codable Tests

    func testSharedMovieEncodingAndDecoding() {
        // Given
        let movie = SharedMovie(
            id: 999,
            title: "Codable Test",
            overview: "Testing encoding and decoding",
            posterPath: "/codable-test.jpg"
        )

        // When
        do {
            let encodedData = try JSONEncoder().encode(movie)
            let decodedMovie = try JSONDecoder().decode(SharedMovie.self, from: encodedData)

            // Then
            XCTAssertEqual(decodedMovie.id, movie.id)
            XCTAssertEqual(decodedMovie.title, movie.title)
            XCTAssertEqual(decodedMovie.overview, movie.overview)
            XCTAssertEqual(decodedMovie.posterPath, movie.posterPath)
        } catch {
            XCTFail("Should not throw error during encoding/decoding: \(error)")
        }
    }
}
