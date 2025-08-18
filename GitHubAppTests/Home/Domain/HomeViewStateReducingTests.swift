//
//  HomeViewStateReducingTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import XCTest

final class HomeViewStateReducingTests: XCTestCase {
    private var sut: HomeViewStateReducer!

    override func setUp() {
        super.setUp()
        sut = HomeViewStateReducer()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testReduceErrorState() {
        // Given
        let errorMessage = "Network error occurred"
        let domainState = HomeDomainState(
            movies: [],
            likedMovies: [],
            isLoading: false,
            error: errorMessage,
            searchQuery: nil
        )

        // When
        let viewState = sut.reduce(domainState)

        // Then
        if case let .error(message) = viewState {
            XCTAssertEqual(message, errorMessage)
        } else {
            XCTFail("Expected error state but got: \(viewState)")
        }
    }

    func testReduceLoadingState() {
        // Given
        let domainState = HomeDomainState(
            movies: [],
            likedMovies: [],
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
            XCTFail("Expected loading state but got: \(viewState)")
        }
    }

    func testReduceSuccessStateWithoutSearchQuery() {
        // Given
        let movie1 = createMockMovie(id: 1, title: "Movie 1")
        let movie2 = createMockMovie(id: 2, title: "Movie 2")
        let likedMovie = createMockMovie(id: 3, title: "Liked Movie")

        let domainState = HomeDomainState(
            movies: [movie1, movie2],
            likedMovies: [likedMovie],
            isLoading: false,
            error: nil,
            searchQuery: nil
        )

        // When
        let viewState = sut.reduce(domainState)

        // Then
        if case let .success(dataViewState) = viewState {
            XCTAssertEqual(dataViewState.title, "Upcoming Movies")
            XCTAssertEqual(dataViewState.movies.count, 2)
            XCTAssertEqual(dataViewState.likedMovies.count, 1)
            XCTAssertNil(dataViewState.searchQuery)
            XCTAssertEqual(dataViewState.movies.first?.title, "Movie 1")
            XCTAssertEqual(dataViewState.likedMovies.first?.title, "Liked Movie")
        } else {
            XCTFail("Expected success state but got: \(viewState)")
        }
    }

    func testReduceSuccessStateWithSearchQuery() {
        // Given
        let movie1 = createMockMovie(id: 1, title: "Search Result 1")
        let movie2 = createMockMovie(id: 2, title: "Search Result 2")
        let searchQuery = "test query"

        let domainState = HomeDomainState(
            movies: [movie1, movie2],
            likedMovies: [],
            isLoading: false,
            error: nil,
            searchQuery: searchQuery
        )

        // When
        let viewState = sut.reduce(domainState)

        // Then
        if case let .success(dataViewState) = viewState {
            XCTAssertEqual(dataViewState.title, "Search Results")
            XCTAssertEqual(dataViewState.movies.count, 2)
            XCTAssertTrue(dataViewState.likedMovies.isEmpty)
            XCTAssertEqual(dataViewState.searchQuery, searchQuery)
            XCTAssertEqual(dataViewState.movies.first?.title, "Search Result 1")
        } else {
            XCTFail("Expected success state but got: \(viewState)")
        }
    }

    func testReduceErrorStatePrioritizedOverLoading() {
        // Given - State with both error and loading
        let domainState = HomeDomainState(
            movies: [],
            likedMovies: [],
            isLoading: true,
            error: "Error message",
            searchQuery: nil
        )

        // When
        let viewState = sut.reduce(domainState)

        // Then - Error should be prioritized over loading
        if case let .error(message) = viewState {
            XCTAssertEqual(message, "Error message")
        } else {
            XCTFail("Expected error state to be prioritized but got: \(viewState)")
        }
    }

    func testReduceEmptySuccessState() {
        // Given
        let domainState = HomeDomainState(
            movies: [],
            likedMovies: [],
            isLoading: false,
            error: nil,
            searchQuery: nil
        )

        // When
        let viewState = sut.reduce(domainState)

        // Then
        if case let .success(dataViewState) = viewState {
            XCTAssertEqual(dataViewState.title, "Upcoming Movies")
            XCTAssertTrue(dataViewState.movies.isEmpty)
            XCTAssertTrue(dataViewState.likedMovies.isEmpty)
            XCTAssertNil(dataViewState.searchQuery)
        } else {
            XCTFail("Expected success state but got: \(viewState)")
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
