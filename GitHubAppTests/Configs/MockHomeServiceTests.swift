//
//  MockHomeServiceTests.swift
//  GitHubAppTests
//

import Combine
@testable import GitHubApp
import XCTest

final class MockHomeServiceTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = .init()

    func testFetchMoviesEmitsResults() {
        let sut = MockHomeService()

        let exp = expectation(description: "movies")
        sut.fetchMovies()
            .sink(receiveCompletion: { _ in }, receiveValue: { response in
                XCTAssertFalse(response.results.isEmpty)
                exp.fulfill()
            })
            .store(in: &cancellables)
        wait(for: [exp], timeout: 1)
    }

    func testSearchMoviesEmitsResults() {
        let sut = MockHomeService()

        let exp = expectation(description: "search")
        sut.searchMovies(with: "query")
            .sink(receiveCompletion: { _ in }, receiveValue: { response in
                XCTAssertFalse(response.results.isEmpty)
                exp.fulfill()
            })
            .store(in: &cancellables)
        wait(for: [exp], timeout: 1)
    }

    func testFetchCreditsEmitsCast() {
        let sut = MockHomeService()

        let exp = expectation(description: "credits")
        sut.fetchCredits(with: 1)
            .sink(receiveCompletion: { _ in }, receiveValue: { response in
                XCTAssertFalse(response.cast.isEmpty)
                exp.fulfill()
            })
            .store(in: &cancellables)
        wait(for: [exp], timeout: 1)
    }

    func testFetchReviewsEmitsReviews() {
        let sut = MockHomeService()

        let exp = expectation(description: "reviews")
        sut.fetchReviews(with: 1)
            .sink(receiveCompletion: { _ in }, receiveValue: { response in
                XCTAssertFalse(response.results.isEmpty)
                exp.fulfill()
            })
            .store(in: &cancellables)
        wait(for: [exp], timeout: 1)
    }
}
