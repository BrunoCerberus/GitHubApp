//
//  MovieDetailsViewModelTests.swift
//  GitHubAppTests
//

import Combine
@testable import GitHubApp
import XCTest

final class MovieDetailsViewModelTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = .init()

    override func setUp() {
        super.setUp()
        try? APIKeysProvider.setMovieAPIKey("md-key")
    }

    override func tearDown() {
        try? APIKeysProvider.removeMovieAPIKey()
        cancellables.removeAll()
        super.tearDown()
    }

    func testFetchDataSetsCreditsAndReviews() {
        let movie = Movie(id: 999, title: "T", overview: "O", posterPath: nil)
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: MockHomeService())
        let sut = MovieDetailsViewModel(movie: movie, serviceLocator: serviceLocator)

        let exp = expectation(description: "details")
        sut.fetchData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(sut.data.credits.isEmpty)
            XCTAssertFalse(sut.data.reviews.isEmpty)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    func testErrorHandlingSetsError() {
        struct FailingService: HomeService {
            func fetchMovies() -> AnyPublisher<MoviesResponse, Error> { Fail(error: NSError(domain: "e", code: 1)).eraseToAnyPublisher() }
            func searchMovies(with _: String) -> AnyPublisher<MoviesResponse, Error> { Fail(error: NSError(domain: "e", code: 1)).eraseToAnyPublisher() }
            func fetchCredits(with _: Int) -> AnyPublisher<MovieCreditsResponse, Error> { Fail(error: NSError(domain: "e", code: 1)).eraseToAnyPublisher() }
            func fetchReviews(with _: Int) -> AnyPublisher<MovieReviewsResponse, Error> { Fail(error: NSError(domain: "e", code: 1)).eraseToAnyPublisher() }
        }

        let movie = Movie(id: 1, title: "T", overview: "O", posterPath: nil)
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: FailingService())
        let sut = MovieDetailsViewModel(movie: movie, serviceLocator: serviceLocator)
        let exp = expectation(description: "error")
        sut.fetchData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNotNil(sut.error)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
}
