//
//  SearchViewStateReducingTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import Testing

struct SearchViewStateReducingTests {
    @Test("Reducer converts domain error state to view error state")
    func reduceErrorState() {
        // Given
        let sut = SearchViewStateReducer()
        let errorMessage = "Network error occurred"
        let domainState = SearchDomainState(
            movies: [],
            favoriteMovies: [],
            isLoading: false,
            error: errorMessage,
            searchQuery: nil
        )

        // When
        let viewState = sut.reduce(domainState)

        // Then
        if case let .error(message) = viewState {
            #expect(message == errorMessage)
        } else {
            Issue.record("Expected error state but got: \(viewState)")
        }
    }

    @Test("Reducer converts domain loading state to view loading state")
    func reduceLoadingState() {
        // Given
        let sut = SearchViewStateReducer()
        let domainState = SearchDomainState(
            movies: [],
            favoriteMovies: [],
            isLoading: true,
            error: nil,
            searchQuery: nil
        )

        // When
        let viewState = sut.reduce(domainState)

        // Then
        if case .loading = viewState {
            // Success - loading state correctly reduced
        } else {
            Issue.record("Expected loading state but got: \(viewState)")
        }
    }

    @Test("Reducer converts success state with search results to view")
    func reduceSuccessStateWithSearchResults() {
        // Given
        let sut = SearchViewStateReducer()
        let movie1 = createMockMovie(id: 1, title: "Search Result 1")
        let movie2 = createMockMovie(id: 2, title: "Search Result 2")
        let likedMovie = createMockMovie(id: 3, title: "Liked Movie")
        let searchQuery = "test query"

        let domainState = SearchDomainState(
            movies: [movie1, movie2],
            favoriteMovies: [likedMovie],
            isLoading: false,
            error: nil,
            searchQuery: searchQuery
        )

        // When
        let viewState = sut.reduce(domainState)

        // Then
        if case let .success(dataViewState) = viewState {
            #expect(dataViewState.movies.count == 2)
            #expect(dataViewState.favoriteMovies.count == 1)
            #expect(dataViewState.searchQuery == searchQuery)
            #expect(dataViewState.movies.first?.title == "Search Result 1")
            #expect(dataViewState.favoriteMovies.first?.title == "Liked Movie")
        } else {
            Issue.record("Expected success state but got: \(viewState)")
        }
    }

    @Test("Reducer handles empty search results correctly")
    func reduceEmptySearchResults() {
        // Given
        let sut = SearchViewStateReducer()
        let domainState = SearchDomainState(
            movies: [],
            favoriteMovies: [],
            isLoading: false,
            error: nil,
            searchQuery: "empty query"
        )

        // When
        let viewState = sut.reduce(domainState)

        // Then
        if case let .success(dataViewState) = viewState {
            #expect(dataViewState.movies.isEmpty)
            #expect(dataViewState.favoriteMovies.isEmpty)
            #expect(dataViewState.searchQuery == "empty query")
        } else {
            Issue.record("Expected success state but got: \(viewState)")
        }
    }

    @Test("Error state is prioritized over loading state")
    func reduceErrorStatePrioritizedOverLoading() {
        // Given - State with both error and loading
        let sut = SearchViewStateReducer()
        let domainState = SearchDomainState(
            movies: [],
            favoriteMovies: [],
            isLoading: true,
            error: "Error message",
            searchQuery: nil
        )

        // When
        let viewState = sut.reduce(domainState)

        // Then - Error should be prioritized over loading
        if case let .error(message) = viewState {
            #expect(message == "Error message")
        } else {
            Issue.record("Expected error state to be prioritized but got: \(viewState)")
        }
    }

    @Test("Reducer handles nil search query")
    func reduceStateWithNilSearchQuery() {
        // Given
        let sut = SearchViewStateReducer()
        let domainState = SearchDomainState(
            movies: [],
            favoriteMovies: [],
            isLoading: false,
            error: nil,
            searchQuery: nil
        )

        // When
        let viewState = sut.reduce(domainState)

        // Then
        if case let .success(dataViewState) = viewState {
            #expect(dataViewState.searchQuery == nil)
            #expect(dataViewState.movies.isEmpty)
        } else {
            Issue.record("Expected success state but got: \(viewState)")
        }
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
