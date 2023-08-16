//
//  HomeNavigationRouterTests.swift
//  GitHubAppTests
//
//  Created by bruno on 16/08/23.
//

import XCTest
@testable import GitHubApp

final class HomeNavigationRouterTests: XCTestCase {
    func testRouter() {
        let mockMovie = Movie(id: 0, title: "The Movie", overview: "", posterPath: nil)
        let nav = UINavigationController(rootViewController: UIViewController())
        let router = HomeNavigationRouter()
        router.navigation = nav
        router.route(navigationEvent: .detail(mockMovie))
        let expectation = self.expectation(description: "Wait for UI")
        
        Task { @MainActor in
            XCTAssertTrue(router.navigation?.topViewController is MovieDetailsHostingController)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
