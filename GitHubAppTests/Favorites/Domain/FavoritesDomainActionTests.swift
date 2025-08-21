//
//  FavoritesDomainActionTests.swift
//  GitHubAppTests
//
//  Created by bruno on feature/liked-clean-architecture.
//

@testable import GitHubApp
import XCTest

final class FavoritesDomainActionTests: XCTestCase {
    func testFavoritesDomainActionEquality() {
        // Given
        let movie1 = Movie(id: 1, title: "Test Movie 1", overview: "Overview 1", posterPath: "/test1.jpg")
        let movie2 = Movie(id: 2, title: "Test Movie 2", overview: "Overview 2", posterPath: "/test2.jpg")

        // When & Then - Test equality
        XCTAssertEqual(FavoritesDomainAction.loadFavoriteMovies, FavoritesDomainAction.loadFavoriteMovies)
        XCTAssertEqual(FavoritesDomainAction.clearAllFavoriteMovies, FavoritesDomainAction.clearAllFavoriteMovies)
        XCTAssertEqual(FavoritesDomainAction.refreshFavoriteMovies, FavoritesDomainAction.refreshFavoriteMovies)
        XCTAssertEqual(FavoritesDomainAction.toggleMovieFavorite(movie1), FavoritesDomainAction.toggleMovieFavorite(movie1))

        // Test inequality
        XCTAssertNotEqual(FavoritesDomainAction.loadFavoriteMovies, FavoritesDomainAction.clearAllFavoriteMovies)
        XCTAssertNotEqual(FavoritesDomainAction.toggleMovieFavorite(movie1), FavoritesDomainAction.toggleMovieFavorite(movie2))
    }

    func testToggleMovieLikeAction() {
        // Given
        let movie = Movie(id: 1, title: "Test Movie", overview: "Test Overview", posterPath: "/test.jpg")

        // When
        let action = FavoritesDomainAction.toggleMovieFavorite(movie)

        // Then
        if case let .toggleMovieFavorite(actionMovie) = action {
            XCTAssertEqual(actionMovie, movie)
        } else {
            XCTFail("Expected toggleMovieFavorite action")
        }
    }
}
