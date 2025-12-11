//
//  HomeDomainStateTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import Testing

@MainActor
struct HomeDomainStateTests {
    @Test("Initial state has empty collections and default values")
    func initialState() {
        let state = HomeDomainState.initial

        #expect(state.movies.isEmpty)
        #expect(state.favoriteMovies.isEmpty)
        #expect(!state.isLoading)
        #expect(state.error == nil)
        #expect(state.searchQuery == nil)
    }

    @Test("State correctly stores movies and loading state")
    func stateWithMoviesAndLoading() {
        let movie = createMockMovie(id: 1, title: "Test Movie")

        let loadingState = HomeDomainState(
            movies: [],
            favoriteMovies: [],
            isLoading: true,
            error: nil,
            searchQuery: nil
        )

        let successState = HomeDomainState(
            movies: [movie],
            favoriteMovies: [],
            isLoading: false,
            error: nil,
            searchQuery: nil
        )

        #expect(loadingState.isLoading)
        #expect(successState.movies.count == 1)
        #expect(successState.movies.first?.title == "Test Movie")
    }

    @Test("State correctly stores error message")
    func stateWithError() {
        let errorState = HomeDomainState(
            movies: [],
            favoriteMovies: [],
            isLoading: false,
            error: "Network error",
            searchQuery: nil
        )

        #expect(!errorState.isLoading)
        #expect(errorState.error == "Network error")
    }

    @Test("State correctly stores search query")
    func stateWithSearchQuery() {
        let movie = createMockMovie(id: 1, title: "Test Movie")

        let searchState = HomeDomainState(
            movies: [movie],
            favoriteMovies: [],
            isLoading: false,
            error: nil,
            searchQuery: "test query"
        )

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
