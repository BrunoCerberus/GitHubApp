//
//  SearchDomainStateTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import Testing

struct SearchDomainStateTests {
    @Test("Initial state has empty collections and default values")
    func initialState() {
        // Given/When
        let state = SearchDomainState.initial

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

        let state1 = SearchDomainState(
            movies: [movie1],
            favoriteMovies: [movie2],
            isLoading: true,
            error: "Error",
            searchQuery: "query"
        )

        let state2 = SearchDomainState(
            movies: [movie1],
            favoriteMovies: [movie2],
            isLoading: true,
            error: "Error",
            searchQuery: "query"
        )

        let state3 = SearchDomainState(
            movies: [movie2], // Different movies
            favoriteMovies: [movie2],
            isLoading: true,
            error: "Error",
            searchQuery: "query"
        )

        // Then
        #expect(state1 == state2)
        #expect(state1 != state3)
        #expect(state1 != SearchDomainState.initial)
    }

    @Test("State properties work correctly with different values")
    func stateWithDifferentProperties() {
        // Given
        let movie = createMockMovie(id: 1, title: "Test Movie")

        let loadingState = SearchDomainState(
            movies: [],
            favoriteMovies: [],
            isLoading: true,
            error: nil,
            searchQuery: nil
        )

        let errorState = SearchDomainState(
            movies: [],
            favoriteMovies: [],
            isLoading: false,
            error: "Network error",
            searchQuery: nil
        )

        let successState = SearchDomainState(
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
        #expect(successState.searchQuery == "test query")
    }

    @Test("Search query state is properly maintained")
    func searchQueryState() {
        // Given
        let query = "avengers"
        let state = SearchDomainState(
            movies: [],
            favoriteMovies: [],
            isLoading: false,
            error: nil,
            searchQuery: query
        )

        // Then
        #expect(state.searchQuery == query)
    }

    @Test("Empty search query state")
    func emptySearchQueryState() {
        // Given
        let state = SearchDomainState(
            movies: [],
            favoriteMovies: [],
            isLoading: false,
            error: nil,
            searchQuery: nil
        )

        // Then
        #expect(state.searchQuery == nil)
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
