//
//  HomeDomainEventActionMapTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import XCTest

final class HomeDomainEventActionMapTests: XCTestCase {
    func testMapFetchDataEvent() {
        // Given
        let event = HomeViewEvent.fetchData

        // When
        let action = HomeDomainEventActionMap.map(event)

        // Then
        XCTAssertEqual(action, HomeDomainAction.fetchUpcomingMovies)
    }

    func testMapSearchMoviesEvent() {
        // Given
        let query = "test query"
        let event = HomeViewEvent.searchMovies(query)

        // When
        let action = HomeDomainEventActionMap.map(event)

        // Then
        XCTAssertEqual(action, HomeDomainAction.searchMovies(query))
    }

    func testMapToggleLikeEvent() {
        // Given
        let movie = createMockMovie(id: 1, title: "Test Movie")
        let event = HomeViewEvent.toggleLike(movie)

        // When
        let action = HomeDomainEventActionMap.map(event)

        // Then
        XCTAssertEqual(action, HomeDomainAction.toggleMovieLike(movie))
    }

    func testMapLoadLikedMoviesEvent() {
        // Given
        let event = HomeViewEvent.loadLikedMovies

        // When
        let action = HomeDomainEventActionMap.map(event)

        // Then
        XCTAssertEqual(action, HomeDomainAction.loadPersistedLikedMovies)
    }

    func testAllViewEventsAreMapped() {
        // Given
        let movie = createMockMovie(id: 1, title: "Test Movie")
        let events: [HomeViewEvent] = [
            .fetchData,
            .searchMovies("query"),
            .toggleLike(movie),
            .loadLikedMovies,
        ]

        // When/Then - Verify all events can be mapped without throwing
        for event in events {
            let action = HomeDomainEventActionMap.map(event)
            XCTAssertNotNil(action, "Failed to map event: \(event)")
        }
    }

    func testMappingConsistency() {
        // Given
        let movie = createMockMovie(id: 1, title: "Test Movie")
        let query = "consistent query"

        // When - Map the same events multiple times
        let action1 = HomeDomainEventActionMap.map(.fetchData)
        let action2 = HomeDomainEventActionMap.map(.fetchData)

        let action3 = HomeDomainEventActionMap.map(.searchMovies(query))
        let action4 = HomeDomainEventActionMap.map(.searchMovies(query))

        let action5 = HomeDomainEventActionMap.map(.toggleLike(movie))
        let action6 = HomeDomainEventActionMap.map(.toggleLike(movie))

        let action7 = HomeDomainEventActionMap.map(.loadLikedMovies)
        let action8 = HomeDomainEventActionMap.map(.loadLikedMovies)

        // Then - Verify mapping is consistent
        XCTAssertEqual(action1, action2)
        XCTAssertEqual(action3, action4)
        XCTAssertEqual(action5, action6)
        XCTAssertEqual(action7, action8)
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
