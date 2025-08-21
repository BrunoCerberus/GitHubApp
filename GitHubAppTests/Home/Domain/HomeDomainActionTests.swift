//
//  HomeDomainActionTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import XCTest

final class HomeDomainActionTests: XCTestCase {
    func testHomeDomainActionEquality() {
        // Given
        let action1 = HomeDomainAction.fetchUpcomingMovies
        let action2 = HomeDomainAction.fetchUpcomingMovies
        let action3 = HomeDomainAction.searchMovies("test")
        let action4 = HomeDomainAction.searchMovies("test")
        let action5 = HomeDomainAction.searchMovies("different")

        let movie = createMockMovie(id: 1, title: "Test Movie")
        let action6 = HomeDomainAction.toggleMovieFavorite(movie)
        let action7 = HomeDomainAction.toggleMovieFavorite(movie)

        let action8 = HomeDomainAction.loadPersistedFavoriteMovies
        let action9 = HomeDomainAction.loadPersistedFavoriteMovies

        // Then
        XCTAssertEqual(action1, action2)
        XCTAssertEqual(action3, action4)
        XCTAssertEqual(action6, action7)
        XCTAssertEqual(action8, action9)

        XCTAssertNotEqual(action1, action3)
        XCTAssertNotEqual(action3, action5)
        XCTAssertNotEqual(action1, action6)
        XCTAssertNotEqual(action1, action8)
    }

    func testHomeDomainActionCases() {
        // Given/When/Then
        let fetchAction = HomeDomainAction.fetchUpcomingMovies
        let searchAction = HomeDomainAction.searchMovies("query")
        let toggleAction = HomeDomainAction.toggleMovieFavorite(createMockMovie(id: 1, title: "Test"))
        let loadAction = HomeDomainAction.loadPersistedFavoriteMovies

        // Verify that all cases can be instantiated
        XCTAssertNotNil(fetchAction)
        XCTAssertNotNil(searchAction)
        XCTAssertNotNil(toggleAction)
        XCTAssertNotNil(loadAction)
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
