//
//  LikedServiceTests.swift
//  GitHubAppTests
//
//  Created by bruno on feature/liked-clean-architecture.
//

import Combine
@testable import GitHubApp
import XCTest

final class LikedServiceTests: XCTestCase {
    private var sut: LikedService!
    private var mockUserDefaults: UserDefaults!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockUserDefaults = UserDefaults(suiteName: "LikedServiceTests")
        mockUserDefaults.removePersistentDomain(forName: "LikedServiceTests")
        sut = LikedService(userDefaults: mockUserDefaults)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        mockUserDefaults.removePersistentDomain(forName: "LikedServiceTests")
        mockUserDefaults = nil
        sut = nil
        cancellables = nil
        super.tearDown()
    }

    func testLoadLikedMoviesEmpty() {
        // Given
        let expectation = XCTestExpectation(description: "Load empty liked movies")
        var result: [Movie]?

        // When
        sut.loadLikedMovies()
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
        let movie = Movie(id: 1, title: "Test Movie", overview: "Test Overview", posterPath: "/test.jpg")
        let expectation = XCTestExpectation(description: "Toggle movie like - add")
        var result: [Movie]?

        // When
        sut.toggleMovieLike(movie)
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
        let movie = Movie(id: 1, title: "Test Movie", overview: "Test Overview", posterPath: "/test.jpg")
        let addExpectation = XCTestExpectation(description: "Add movie")
        let removeExpectation = XCTestExpectation(description: "Remove movie")
        var addResult: [Movie]?
        var removeResult: [Movie]?

        // When - First add the movie
        sut.toggleMovieLike(movie)
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
        sut.toggleMovieLike(movie)
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
        sut.toggleMovieLike(movie)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    addExpectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [addExpectation], timeout: 1.0)

        // Then clear all
        sut.clearAllLikedMovies()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    clearExpectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [clearExpectation], timeout: 1.0)

        // Then load to verify
        sut.loadLikedMovies()
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
        let movie1 = Movie(id: 1, title: "Test Movie 1", overview: "Test Overview 1", posterPath: "/test1.jpg")
        let movie2 = Movie(id: 2, title: "Test Movie 2", overview: "Test Overview 2", posterPath: "/test2.jpg")
        let addExpectation = XCTestExpectation(description: "Add movie")
        let checkExpectation = XCTestExpectation(description: "Check movie liked")
        var isMovie1Liked: Bool?
        var isMovie2Liked: Bool?

        // When - Add movie1
        sut.toggleMovieLike(movie1)
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
