//
//  MovieReviewsTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import XCTest

final class MovieReviewsTests: XCTestCase {
    func testDisplayAuthorFallback() {
        let review = MovieReview(id: "1", author: "", content: "c")
        XCTAssertEqual(review.displayAuthor, "Anonymous")
    }

    func testDisplayContentFallback() {
        let review = MovieReview(id: "1", author: "a", content: "")
        XCTAssertEqual(review.displayContent, "No review content available")
    }
}
