//
//  FavoritesDomainStateTests.swift
//  GitHubAppTests
//
//  Created by bruno on feature/liked-clean-architecture.
//

@testable import GitHubApp
import XCTest

final class FavoritesDomainStateTests: XCTestCase {
    func testInitialState() {
        // When
        let state = FavoritesDomainState.initial

        // Then
        XCTAssertTrue(state.favoriteMovies.isEmpty)
        XCTAssertFalse(state.isLoading)
        XCTAssertNil(state.error)
    }

    func testStateEquality() {
        // Given
        let movie1 = Movie(id: 1, title: "Test Movie 1", overview: "Overview 1", posterPath: "/test1.jpg")
        let movie2 = Movie(id: 2, title: "Test Movie 2", overview: "Overview 2", posterPath: "/test2.jpg")

        let state1 = FavoritesDomainState(favoriteMovies: [movie1], isLoading: false, error: nil)
        let state2 = FavoritesDomainState(favoriteMovies: [movie1], isLoading: false, error: nil)
        let state3 = FavoritesDomainState(favoriteMovies: [movie2], isLoading: false, error: nil)
        let state4 = FavoritesDomainState(favoriteMovies: [movie1], isLoading: true, error: nil)
        let state5 = FavoritesDomainState(favoriteMovies: [movie1], isLoading: false, error: "Error")

        // When & Then
        XCTAssertEqual(state1, state2)
        XCTAssertNotEqual(state1, state3)
        XCTAssertNotEqual(state1, state4)
        XCTAssertNotEqual(state1, state5)
    }

    func testStateWithMovies() {
        // Given
        let movies = [
            Movie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: "/test1.jpg"),
            Movie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: "/test2.jpg"),
        ]

        // When
        let state = FavoritesDomainState(favoriteMovies: movies, isLoading: false, error: nil)

        // Then
        XCTAssertEqual(state.favoriteMovies.count, 2)
        XCTAssertEqual(state.favoriteMovies, movies)
        XCTAssertFalse(state.isLoading)
        XCTAssertNil(state.error)
    }

    func testStateWithError() {
        // Given
        let errorMessage = "Failed to load favorite movies"

        // When
        let state = FavoritesDomainState(favoriteMovies: [], isLoading: false, error: errorMessage)

        // Then
        XCTAssertTrue(state.favoriteMovies.isEmpty)
        XCTAssertFalse(state.isLoading)
        XCTAssertEqual(state.error, errorMessage)
    }

    func testLoadingState() {
        // When
        let state = FavoritesDomainState(favoriteMovies: [], isLoading: true, error: nil)

        // Then
        XCTAssertTrue(state.favoriteMovies.isEmpty)
        XCTAssertTrue(state.isLoading)
        XCTAssertNil(state.error)
    }
}
