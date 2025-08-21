//
//  LikedDomainActionTests.swift
//  GitHubAppTests
//
//  Created by bruno on feature/liked-clean-architecture.
//

@testable import GitHubApp
import XCTest

final class LikedDomainActionTests: XCTestCase {
    func testLikedDomainActionEquality() {
        // Given
        let movie1 = Movie(id: 1, title: "Test Movie 1", overview: "Overview 1", posterPath: "/test1.jpg")
        let movie2 = Movie(id: 2, title: "Test Movie 2", overview: "Overview 2", posterPath: "/test2.jpg")

        // When & Then - Test equality
        XCTAssertEqual(LikedDomainAction.loadLikedMovies, LikedDomainAction.loadLikedMovies)
        XCTAssertEqual(LikedDomainAction.clearAllLikedMovies, LikedDomainAction.clearAllLikedMovies)
        XCTAssertEqual(LikedDomainAction.refreshLikedMovies, LikedDomainAction.refreshLikedMovies)
        XCTAssertEqual(LikedDomainAction.toggleMovieLike(movie1), LikedDomainAction.toggleMovieLike(movie1))

        // Test inequality
        XCTAssertNotEqual(LikedDomainAction.loadLikedMovies, LikedDomainAction.clearAllLikedMovies)
        XCTAssertNotEqual(LikedDomainAction.toggleMovieLike(movie1), LikedDomainAction.toggleMovieLike(movie2))
    }

    func testToggleMovieLikeAction() {
        // Given
        let movie = Movie(id: 1, title: "Test Movie", overview: "Test Overview", posterPath: "/test.jpg")

        // When
        let action = LikedDomainAction.toggleMovieLike(movie)

        // Then
        if case let .toggleMovieLike(actionMovie) = action {
            XCTAssertEqual(actionMovie, movie)
        } else {
            XCTFail("Expected toggleMovieLike action")
        }
    }
}
