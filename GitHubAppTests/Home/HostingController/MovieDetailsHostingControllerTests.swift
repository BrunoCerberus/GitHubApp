//
//  MovieDetailsHostingControllerTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import UIKit
import XCTest

final class MovieDetailsHostingControllerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Ensure API key is available to avoid fatalError in HomeAPI
        try? APIKeysProvider.setMovieAPIKey("test-key")
    }

    override func tearDown() {
        try? APIKeysProvider.removeMovieAPIKey()
        super.tearDown()
    }

    func testViewDidLoadSetsTitleFromMovie() {
        let movie = Movie(id: 7, title: "Seven", overview: "o", posterPath: nil)
        let sut = MovieDetailsHostingController(movie: movie)
        _ = UINavigationController(rootViewController: sut)

        // Trigger lifecycle
        _ = sut.view
        sut.viewDidLoad()

        XCTAssertEqual(sut.title, movie.title)
    }

    func testInitialization() {
        let movie = Movie(id: 123, title: "Test Movie", overview: "Test overview", posterPath: "/test.jpg")
        let sut = MovieDetailsHostingController(movie: movie)

        XCTAssertEqual(sut.movie.id, movie.id)
        XCTAssertEqual(sut.movie.title, movie.title)
        XCTAssertNotNil(sut.view)
    }

    @MainActor
    func testInitWithCoderReturnsNil() {
        let sut = MovieDetailsHostingController(coder: NSCoder())

        XCTAssertNil(sut)
    }
}
