//
//  HomeNavigationRouterTests.swift
//  GitHubAppTests
//
//  Created by bruno on 16/08/23.
//

@testable import GitHubApp
import XCTest

/**
 * UI routing tests for HomeNavigationRouter using a UINavigationController fallback path.
 */
final class HomeNavigationRouterTests: XCTestCase {
    /// Pushing a detail event presents MovieDetailsHostingController
    func testRouter() {
        let mockMovie = Movie(id: 0, title: "The Movie", overview: "", posterPath: nil)
        let nav = UINavigationController(rootViewController: UIViewController())
        let serviceLocator = ServiceLocator()
        let router = HomeNavigationRouter(serviceLocator: serviceLocator)
        router.navigation = nav
        router.route(navigationEvent: .detail(mockMovie))
        let expectation: XCTestExpectation = expectation(description: "Wait for UI")

        Task { @MainActor in
            XCTAssertTrue(router.navigation?.topViewController is MovieDetailsHostingController)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.1, handler: nil)
    }
}
