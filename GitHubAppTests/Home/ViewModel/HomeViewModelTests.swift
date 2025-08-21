//
//  HomeViewModelTests.swift
//  GitHubAppTests
//

import Combine
@testable import GitHubApp
import XCTest

final class HomeViewModelTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = .init()

    override func setUp() {
        super.setUp()
        StorageServiceFactory.shared.resetCache()
        // Ensure API key exists in case anything inadvertently touches HomeAPI
        try? APIKeysProvider.setMovieAPIKey("unit-test-key")
    }

    override func tearDown() {
        StorageServiceFactory.shared.resetCache()
        try? APIKeysProvider.removeMovieAPIKey()
        cancellables.removeAll()
        super.tearDown()
    }

    func testFetchDataPopulatesMoviesAndFavoritesSync() {
        let service = MockHomeService()
        let sut = HomeViewModel(service: service)

        let exp = expectation(description: "movies")
        // Give the Combine pipeline a short moment; MockHomeService uses RunLoop delivery
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(sut.movies.isEmpty)
            XCTAssertTrue(sut.favoriteMovies.isEmpty)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    func testSearchMoviesReplacesMovies() {
        let service = MockHomeService()
        let sut = HomeViewModel(service: service)

        let exp = expectation(description: "search")
        sut.searchMovies(query: "barbie")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(sut.movies.isEmpty)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
}
