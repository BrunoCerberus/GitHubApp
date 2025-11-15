//
//  HomeViewStateReducingTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import Testing

@MainActor
struct HomeViewStateReducingTests {
    @Test("Reducer converts domain error state to view error state")
    func reduceErrorState() {
        // Given
        let sut = HomeViewStateReducer()
        let errorMessage = "Network error occurred"
        let domainState = HomeDomainState(
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
        let sut = HomeViewStateReducer()
        let domainState = HomeDomainState(
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

    @Test("Reducer converts success state without search query to upcoming movies view")
    func reduceSuccessStateWithoutSearchQuery() {
        // Given
        let sut = HomeViewStateReducer()
        let movie1 = createMockMovie(id: 1, title: "Movie 1")
        let movie2 = createMockMovie(id: 2, title: "Movie 2")
        let likedMovie = createMockMovie(id: 3, title: "Liked Movie")

        let domainState = HomeDomainState(
            movies: [movie1, movie2],
            favoriteMovies: [likedMovie],
            isLoading: false,
            error: nil,
            searchQuery: nil
        )

        // When
        let viewState = sut.reduce(domainState)

        // Then
        if case let .success(dataViewState) = viewState {
            #expect(dataViewState.title == "Upcoming Movies")
            #expect(dataViewState.movies.count == 2)
            #expect(dataViewState.favoriteMovies.count == 1)
            #expect(dataViewState.searchQuery == nil)
            #expect(dataViewState.movies.first?.title == "Movie 1")
            #expect(dataViewState.favoriteMovies.first?.title == "Liked Movie")
        } else {
            Issue.record("Expected success state but got: \(viewState)")
        }
    }

    @Test("Reducer converts success state with search query to search results view")
    func reduceSuccessStateWithSearchQuery() {
        // Given
        let sut = HomeViewStateReducer()
        let movie1 = createMockMovie(id: 1, title: "Search Result 1")
        let movie2 = createMockMovie(id: 2, title: "Search Result 2")
        let searchQuery = "test query"

        let domainState = HomeDomainState(
            movies: [movie1, movie2],
            favoriteMovies: [],
            isLoading: false,
            error: nil,
            searchQuery: searchQuery
        )

        // When
        let viewState = sut.reduce(domainState)

        // Then
        if case let .success(dataViewState) = viewState {
            #expect(dataViewState.title == "Search Results")
            #expect(dataViewState.movies.count == 2)
            #expect(dataViewState.favoriteMovies.isEmpty)
            #expect(dataViewState.searchQuery == searchQuery)
            #expect(dataViewState.movies.first?.title == "Search Result 1")
        } else {
            Issue.record("Expected success state but got: \(viewState)")
        }
    }

    @Test("Error state is prioritized over loading state")
    func reduceErrorStatePrioritizedOverLoading() {
        // Given - State with both error and loading
        let sut = HomeViewStateReducer()
        let domainState = HomeDomainState(
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

    @Test("Reducer handles empty success state correctly")
    func reduceEmptySuccessState() {
        // Given
        let sut = HomeViewStateReducer()
        let domainState = HomeDomainState(
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
            #expect(dataViewState.title == "Upcoming Movies")
            #expect(dataViewState.movies.isEmpty)
            #expect(dataViewState.favoriteMovies.isEmpty)
            #expect(dataViewState.searchQuery == nil)
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
