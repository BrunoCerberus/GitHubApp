//
//  HomeDomainStateTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import XCTest

final class HomeDomainStateTests: XCTestCase {
    func testInitialState() {
        // Given/When
        let state = HomeDomainState.initial

        // Then
        XCTAssertTrue(state.movies.isEmpty)
        XCTAssertTrue(state.likedMovies.isEmpty)
        XCTAssertFalse(state.isLoading)
        XCTAssertNil(state.error)
        XCTAssertNil(state.searchQuery)
    }

    func testStateEquality() {
        // Given
        let movie1 = createMockMovie(id: 1, title: "Movie 1")
        let movie2 = createMockMovie(id: 2, title: "Movie 2")

        let state1 = HomeDomainState(
            movies: [movie1],
            likedMovies: [movie2],
            isLoading: true,
            error: "Error",
            searchQuery: "query"
        )

        let state2 = HomeDomainState(
            movies: [movie1],
            likedMovies: [movie2],
            isLoading: true,
            error: "Error",
            searchQuery: "query"
        )

        let state3 = HomeDomainState(
            movies: [movie2], // Different movies
            likedMovies: [movie2],
            isLoading: true,
            error: "Error",
            searchQuery: "query"
        )

        // Then
        XCTAssertEqual(state1, state2)
        XCTAssertNotEqual(state1, state3)
        XCTAssertNotEqual(state1, HomeDomainState.initial)
    }

    func testStateWithDifferentProperties() {
        // Given
        let movie = createMockMovie(id: 1, title: "Test Movie")

        let loadingState = HomeDomainState(
            movies: [],
            likedMovies: [],
            isLoading: true,
            error: nil,
            searchQuery: nil
        )

        let errorState = HomeDomainState(
            movies: [],
            likedMovies: [],
            isLoading: false,
            error: "Network error",
            searchQuery: nil
        )

        let successState = HomeDomainState(
            movies: [movie],
            likedMovies: [],
            isLoading: false,
            error: nil,
            searchQuery: nil
        )

        let searchState = HomeDomainState(
            movies: [movie],
            likedMovies: [],
            isLoading: false,
            error: nil,
            searchQuery: "test query"
        )

        // Then
        XCTAssertTrue(loadingState.isLoading)
        XCTAssertNil(loadingState.error)

        XCTAssertFalse(errorState.isLoading)
        XCTAssertEqual(errorState.error, "Network error")

        XCTAssertEqual(successState.movies.count, 1)
        XCTAssertEqual(successState.movies.first?.title, "Test Movie")

        XCTAssertEqual(searchState.searchQuery, "test query")
        XCTAssertEqual(searchState.movies.count, 1)
    }

    // MARK: - Helper Methods

    private func createMockMovie(id: Int, title: String) -> Movie {
        Movie(
            id: id,
            title: title,
            overview: "Test overview",
            posterPath: "/test.jpg"
        )
    }
}
