//
//  MovieDetailsDomainEventActionMapTests.swift
//  GitHubAppTests
//
//  Created by Claude Code
//

import Foundation
@testable import GitHubApp
import Testing

/**
 * Tests for MovieDetailsDomainEventActionMap enum.
 */
struct MovieDetailsDomainEventActionMapTests {
    private let testMovie = Movie(
        id: 999,
        title: "Map Test Movie",
        overview: "Test Overview",
        posterPath: nil
    )

    @Test("maps fetchData view event to fetchMovieDetails domain action")
    func mapsFetchDataViewEventToFetchMovieDetailsDomainAction() {
        let viewEvent = MovieDetailsViewEvent.fetchData
        let domainAction = MovieDetailsDomainEventActionMap.map(viewEvent)

        #expect(domainAction == .fetchMovieDetails)
    }

    @Test("maps toggleFavorite view event to toggleMovieFavorite domain action")
    func mapsToggleFavoriteViewEventToToggleMovieFavoriteDomainAction() {
        let viewEvent = MovieDetailsViewEvent.toggleFavorite(testMovie)
        let domainAction = MovieDetailsDomainEventActionMap.map(viewEvent)

        #expect(domainAction == .toggleMovieFavorite(testMovie))
    }

    @Test("maps toggle favorite with different movies produces different actions")
    func mapsToggleFavoriteWithDifferentMoviesProducesDifferentActions() {
        let movie1 = Movie(id: 1, title: "Movie 1", overview: "Overview", posterPath: nil)
        let movie2 = Movie(id: 2, title: "Movie 2", overview: "Overview", posterPath: nil)

        let viewEvent1 = MovieDetailsViewEvent.toggleFavorite(movie1)
        let viewEvent2 = MovieDetailsViewEvent.toggleFavorite(movie2)

        let domainAction1 = MovieDetailsDomainEventActionMap.map(viewEvent1)
        let domainAction2 = MovieDetailsDomainEventActionMap.map(viewEvent2)

        #expect(domainAction1 != domainAction2)
    }

    @Test("mapping preserves movie data in toggle favorite event")
    func mappingPreservesMovieDataInToggleFavoriteEvent() {
        let movieWithDetails = Movie(
            id: 12345,
            title: "Detailed Movie",
            overview: "A detailed overview of the movie",
            posterPath: "poster.jpg"
        )

        let viewEvent = MovieDetailsViewEvent.toggleFavorite(movieWithDetails)
        let domainAction = MovieDetailsDomainEventActionMap.map(viewEvent)

        if case let .toggleMovieFavorite(mappedMovie) = domainAction {
            #expect(mappedMovie.id == movieWithDetails.id)
            #expect(mappedMovie.title == movieWithDetails.title)
            #expect(mappedMovie.overview == movieWithDetails.overview)
            #expect(mappedMovie.posterPath == movieWithDetails.posterPath)
        } else {
            #expect(Bool(false), "Expected toggleMovieFavorite action")
        }
    }
}
