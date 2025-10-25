//
//  HomeDomainStateTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import Testing

struct HomeDomainStateTests {
    @Test("Initial state has empty collections and default values")
    func initialState() {
        // Given/When
        let state = HomeDomainState.initial

        // Then
        #expect(state.movies.isEmpty)
        #expect(state.favoriteMovies.isEmpty)
        #expect(!state.isLoading)
        #expect(state.error == nil)
        #expect(state.searchQuery == nil)
    }

    @Test("State equality comparison works correctly")
    func stateEquality() {
        // Given
        let movie1 = createMockMovie(id: 1, title: "Movie 1")
        let movie2 = createMockMovie(id: 2, title: "Movie 2")

        let state1 = HomeDomainState(
            movies: [movie1],
            favoriteMovies: [movie2],
            isLoading: true,
            error: "Error",
            searchQuery: "query"
        )

        let state2 = HomeDomainState(
            movies: [movie1],
            favoriteMovies: [movie2],
            isLoading: true,
            error: "Error",
            searchQuery: "query"
        )

        let state3 = HomeDomainState(
            movies: [movie2], // Different movies
            favoriteMovies: [movie2],
            isLoading: true,
            error: "Error",
            searchQuery: "query"
        )

        // Then
        #expect(state1 == state2)
        #expect(state1 != state3)
        #expect(state1 != HomeDomainState.initial)
    }

    @Test("State properties work correctly with different values")
    func stateWithDifferentProperties() {
        // Given
        let movie = createMockMovie(id: 1, title: "Test Movie")

        let loadingState = HomeDomainState(
            movies: [],
            favoriteMovies: [],
            isLoading: true,
            error: nil,
            searchQuery: nil
        )

        let errorState = HomeDomainState(
            movies: [],
            favoriteMovies: [],
            isLoading: false,
            error: "Network error",
            searchQuery: nil
        )

        let successState = HomeDomainState(
            movies: [movie],
            favoriteMovies: [],
            isLoading: false,
            error: nil,
            searchQuery: nil
        )

        let searchState = HomeDomainState(
            movies: [movie],
            favoriteMovies: [],
            isLoading: false,
            error: nil,
            searchQuery: "test query"
        )

        // Then
        #expect(loadingState.isLoading)
        #expect(loadingState.error == nil)

        #expect(!errorState.isLoading)
        #expect(errorState.error == "Network error")

        #expect(successState.movies.count == 1)
        #expect(successState.movies.first?.title == "Test Movie")

        #expect(searchState.searchQuery == "test query")
        #expect(searchState.movies.count == 1)
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
