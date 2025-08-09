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
}
