//
//  MovieTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import XCTest

final class MovieTests: XCTestCase {
    func testDisplayTitleFallback() {
        let movie = Movie(id: 1, title: "", overview: "o", posterPath: nil)
        XCTAssertEqual(movie.displayTitle, "Untitled")
    }

    func testDisplayOverviewFallback() {
        let movie = Movie(id: 1, title: "t", overview: "", posterPath: nil)
        XCTAssertEqual(movie.displayOverview, "No overview available")
    }

    func testPosterURLNilWhenPathMissingOrEmpty() {
        XCTAssertNil(Movie(id: 1, title: "t", overview: "o", posterPath: nil).posterURL)
        XCTAssertNil(Movie(id: 1, title: "t", overview: "o", posterPath: "").posterURL)
    }
}
