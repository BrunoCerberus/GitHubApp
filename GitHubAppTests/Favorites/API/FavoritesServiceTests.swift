//
//  FavoritesServiceTests.swift
//  GitHubAppTests
//
//  Created by bruno on feature/liked-clean-architecture.
//

import Combine
@testable import GitHubApp
import XCTest

final class FavoritesServiceTests: XCTestCase {
    private var sut: FavoritesService!
    private var mockFavoritesService: MockFavoritesService!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockFavoritesService = MockFavoritesService()
        sut = mockFavoritesService
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        mockFavoritesService = nil
        sut = nil
        cancellables = nil
        super.tearDown()
    }

    func testLoadLikedMoviesEmpty() {
        // Given
        let expectation = XCTestExpectation(description: "Load empty favorite movies")
        var result: [Movie]?

        // Clear pre-populated mock data
        mockFavoritesService.setMockLikedMovies([])

        // When
        sut.loadFavoriteMovies()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Expected success but got failure")
                    }
                },
                receiveValue: { movies in
                    result = movies
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.isEmpty ?? false)
    }

    func testToggleMovieLikeAddMovie() {
        // Given
        let movie = Movie(id: 999, title: "Test Movie", overview: "Test Overview", posterPath: "/test.jpg")
        let expectation = XCTestExpectation(description: "Toggle movie like - add")
        var result: [Movie]?

        // Clear pre-populated mock data to start fresh
        mockFavoritesService.setMockLikedMovies([])

        // When
        sut.toggleMovieFavorite(movie)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Expected success but got failure")
                    }
                },
                receiveValue: { movies in
                    result = movies
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(result?.first, movie)
    }

    func testToggleMovieLikeRemoveMovie() {
        // Given
        let movie = Movie(id: 998, title: "Test Movie", overview: "Test Overview", posterPath: "/test.jpg")
        let addExpectation = XCTestExpectation(description: "Add movie")
        let removeExpectation = XCTestExpectation(description: "Remove movie")
        var addResult: [Movie]?
        var removeResult: [Movie]?

        // Clear pre-populated mock data to start fresh
        mockFavoritesService.setMockLikedMovies([])

        // When - First add the movie
        sut.toggleMovieFavorite(movie)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { movies in
                    addResult = movies
                    addExpectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [addExpectation], timeout: 1.0)

        // Then add again to remove
        sut.toggleMovieFavorite(movie)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { movies in
                    removeResult = movies
                    removeExpectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [removeExpectation], timeout: 1.0)

        // Then
        XCTAssertEqual(addResult?.count, 1)
        XCTAssertTrue(removeResult?.isEmpty ?? false)
    }

    func testClearAllLikedMovies() {
        // Given
        let movie = Movie(id: 1, title: "Test Movie", overview: "Test Overview", posterPath: "/test.jpg")
        let addExpectation = XCTestExpectation(description: "Add movie")
        let clearExpectation = XCTestExpectation(description: "Clear all movies")
        let loadExpectation = XCTestExpectation(description: "Load after clear")
        var loadResult: [Movie]?

        // When - First add a movie
        sut.toggleMovieFavorite(movie)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    addExpectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [addExpectation], timeout: 1.0)

        // Then clear all
        sut.clearAllFavoriteMovies()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    clearExpectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [clearExpectation], timeout: 1.0)

        // Then load to verify
        sut.loadFavoriteMovies()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { movies in
                    loadResult = movies
                    loadExpectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [loadExpectation], timeout: 1.0)

        // Then
        XCTAssertTrue(loadResult?.isEmpty ?? false)
    }

    func testIsMovieLiked() {
        // Given
        let movie1 = Movie(id: 997, title: "Test Movie 1", overview: "Test Overview 1", posterPath: "/test1.jpg")
        let movie2 = Movie(id: 996, title: "Test Movie 2", overview: "Test Overview 2", posterPath: "/test2.jpg")
        let addExpectation = XCTestExpectation(description: "Add movie")
        let checkExpectation = XCTestExpectation(description: "Check movie liked")
        var isMovie1Liked: Bool?
        var isMovie2Liked: Bool?

        // Clear pre-populated mock data to start fresh
        mockFavoritesService.setMockLikedMovies([])

        // When - Add movie1
        sut.toggleMovieFavorite(movie1)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    addExpectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [addExpectation], timeout: 1.0)

        // Then check if movies are liked
        Publishers.Zip(
            sut.isMovieLiked(movie1),
            sut.isMovieLiked(movie2)
        )
        .sink(
            receiveCompletion: { _ in },
            receiveValue: { movie1Liked, movie2Liked in
                isMovie1Liked = movie1Liked
                isMovie2Liked = movie2Liked
                checkExpectation.fulfill()
            }
        )
        .store(in: &cancellables)

        wait(for: [checkExpectation], timeout: 1.0)

        // Then
        XCTAssertTrue(isMovie1Liked ?? false)
        XCTAssertFalse(isMovie2Liked ?? true)
    }
}
