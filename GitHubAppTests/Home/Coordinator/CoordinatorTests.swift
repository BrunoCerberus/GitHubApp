//
//  CoordinatorTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import SwiftUI
import XCTest

final class CoordinatorTests: XCTestCase {
    override func setUp() {
        super.setUp()
        try? APIKeysProvider.setMovieAPIKey("coord-key")
    }

    override func tearDown() {
        try? APIKeysProvider.removeMovieAPIKey()
        super.tearDown()
    }

    func testPushAppendsPage() {
        let serviceLocator = ServiceLocator()
        let sut = Coordinator(serviceLocator: serviceLocator)
        XCTAssertTrue(sut.path.isEmpty)
        sut.push(page: .home)
        XCTAssertFalse(sut.path.isEmpty)
    }

    func testBuildHomeAndDetailRender() {
        let serviceLocator = ServiceLocator()
        let sut = Coordinator(serviceLocator: serviceLocator)

        let homeView = sut.build(page: .home)
        let homeHost = UIHostingController(rootView: AnyView(homeView))
        XCTAssertNotNil(homeHost.view)

        let movie = Movie(id: 5, title: "Title", overview: "Overview", posterPath: nil)
        let detailView = sut.build(page: .detail(movie))
        let detailHost = UIHostingController(rootView: AnyView(detailView))
        XCTAssertNotNil(detailHost.view)
    }
}
