//
//  MovieReviewsTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import Testing

struct MovieReviewsTests {
    @Test("Display author falls back to 'Anonymous' when author is empty")
    func displayAuthorFallback() {
        let review = MovieReview(id: "1", author: "", content: "c")
        #expect(review.displayAuthor == "Anonymous")
    }

    @Test("Display content falls back to 'No review content available' when content is empty")
    func displayContentFallback() {
        let review = MovieReview(id: "1", author: "a", content: "")
        #expect(review.displayContent == "No review content available")
    }
}
