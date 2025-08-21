//
//  LikedDomainStateTests.swift
//  GitHubAppTests
//
//  Created by bruno on feature/liked-clean-architecture.
//

@testable import GitHubApp
import XCTest

final class LikedDomainStateTests: XCTestCase {
    func testInitialState() {
        // When
        let state = LikedDomainState.initial

        // Then
        XCTAssertTrue(state.likedMovies.isEmpty)
        XCTAssertFalse(state.isLoading)
        XCTAssertNil(state.error)
    }

    func testStateEquality() {
        // Given
        let movie1 = Movie(id: 1, title: "Test Movie 1", overview: "Overview 1", posterPath: "/test1.jpg")
        let movie2 = Movie(id: 2, title: "Test Movie 2", overview: "Overview 2", posterPath: "/test2.jpg")

        let state1 = LikedDomainState(likedMovies: [movie1], isLoading: false, error: nil)
        let state2 = LikedDomainState(likedMovies: [movie1], isLoading: false, error: nil)
        let state3 = LikedDomainState(likedMovies: [movie2], isLoading: false, error: nil)
        let state4 = LikedDomainState(likedMovies: [movie1], isLoading: true, error: nil)
        let state5 = LikedDomainState(likedMovies: [movie1], isLoading: false, error: "Error")

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
        let state = LikedDomainState(likedMovies: movies, isLoading: false, error: nil)

        // Then
        XCTAssertEqual(state.likedMovies.count, 2)
        XCTAssertEqual(state.likedMovies, movies)
        XCTAssertFalse(state.isLoading)
        XCTAssertNil(state.error)
    }

    func testStateWithError() {
        // Given
        let errorMessage = "Failed to load liked movies"

        // When
        let state = LikedDomainState(likedMovies: [], isLoading: false, error: errorMessage)

        // Then
        XCTAssertTrue(state.likedMovies.isEmpty)
        XCTAssertFalse(state.isLoading)
        XCTAssertEqual(state.error, errorMessage)
    }

    func testLoadingState() {
        // When
        let state = LikedDomainState(likedMovies: [], isLoading: true, error: nil)

        // Then
        XCTAssertTrue(state.likedMovies.isEmpty)
        XCTAssertTrue(state.isLoading)
        XCTAssertNil(state.error)
    }
}
