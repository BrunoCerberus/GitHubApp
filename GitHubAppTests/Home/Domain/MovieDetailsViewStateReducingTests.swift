//
//  MovieDetailsViewStateReducingTests.swift
//  GitHubAppTests
//
//  Created by Claude Code
//

import Foundation
@testable import GitHubApp
import Testing

/**
 * Tests for MovieDetailsViewStateReducing protocol and MovieDetailsViewStateReducer implementation.
 */
struct MovieDetailsViewStateReducingTests {
    private let reducer = MovieDetailsViewStateReducer()

    private let testMovie = Movie(
        id: 789,
        title: "Reducer Test Movie",
        overview: "Test Overview",
        posterPath: "test.jpg"
    )

    private let testCredit = MovieCastMember(
        id: 1,
        name: "Actor Name",
        character: "Character Name"
    )

    private let testReview = MovieReview(
        id: "review1",
        author: "Test Author",
        content: "Test review content"
    )

    @Test("reducer converts loading domain state to loading view state")
    func reducerConvertsLoadingDomainStateToLoadingViewState() {
        let domainState = MovieDetailsDomainState.initial(for: testMovie)

        let viewState = reducer.reduce(domainState)

        if case .loading = viewState {
            // Test passes
        } else {
            #expect(Bool(false), "Expected loading state")
        }
    }

    @Test("reducer converts error domain state to error view state")
    func reducerConvertsErrorDomainStateToErrorViewState() {
        let errorMessage = "Test error message"
        let domainState = MovieDetailsDomainState.initial(for: testMovie).copy(
            isLoading: false,
            error: errorMessage
        )

        let viewState = reducer.reduce(domainState)

        if case let .error(message) = viewState {
            #expect(message == errorMessage)
        } else {
            #expect(Bool(false), "Expected error state")
        }
    }

    @Test("reducer converts success domain state to success view state")
    func reducerConvertsSuccessDomainStateToSuccessViewState() {
        let credits = [testCredit]
        let reviews = [testReview]
        let favorites = [testMovie]

        let domainState = MovieDetailsDomainState(
            movie: testMovie,
            credits: credits,
            reviews: reviews,
            favoriteMovies: favorites,
            isLoading: false,
            error: nil
        )

        let viewState = reducer.reduce(domainState)

        if case let .success(dataViewState) = viewState {
            #expect(dataViewState.movie == testMovie)
            #expect(dataViewState.credits == credits)
            #expect(dataViewState.reviews == reviews)
            #expect(dataViewState.favoriteMovies == favorites)
        } else {
            #expect(Bool(false), "Expected success state")
        }
    }

    @Test("reducer prioritizes error state over loading state")
    func reducerPrioritizesErrorStateOverLoadingState() {
        let domainState = MovieDetailsDomainState.initial(for: testMovie).copy(
            isLoading: true,
            error: "Error occurred"
        )

        let viewState = reducer.reduce(domainState)

        if case let .error(message) = viewState {
            #expect(message == "Error occurred")
        } else {
            #expect(Bool(false), "Expected error state to be prioritized")
        }
    }

    @Test("reducer prioritizes loading state over success state")
    func reducerPrioritizesLoadingStateOverSuccessState() {
        let domainState = MovieDetailsDomainState(
            movie: testMovie,
            credits: [testCredit],
            reviews: [testReview],
            favoriteMovies: [testMovie],
            isLoading: true,
            error: nil
        )

        let viewState = reducer.reduce(domainState)

        if case .loading = viewState {
            // Test passes
        } else {
            #expect(Bool(false), "Expected loading state to be prioritized")
        }
    }

    @Test("reducer creates data view state with all properties")
    func reducerCreatesDataViewStateWithAllProperties() {
        let credits = [testCredit]
        let reviews = [testReview]
        let favorites = [testMovie]

        let domainState = MovieDetailsDomainState(
            movie: testMovie,
            credits: credits,
            reviews: reviews,
            favoriteMovies: favorites,
            isLoading: false,
            error: nil
        )

        let viewState = reducer.reduce(domainState)

        if case let .success(dataViewState) = viewState {
            #expect(dataViewState.movie.id == testMovie.id)
            #expect(dataViewState.credits.count == 1)
            #expect(dataViewState.reviews.count == 1)
            #expect(dataViewState.favoriteMovies.count == 1)
        } else {
            #expect(Bool(false), "Expected success state")
        }
    }
}
