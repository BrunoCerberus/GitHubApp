//
//  MovieTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import Testing

struct MovieTests {
    @Test("Display title falls back to 'Untitled' when title is empty")
    func displayTitleFallback() {
        let movie = Movie(id: 1, title: "", overview: "o", posterPath: nil)
        #expect(movie.displayTitle == "Untitled")
    }

    @Test("Display overview falls back to 'No overview available' when overview is empty")
    func displayOverviewFallback() {
        let movie = Movie(id: 1, title: "t", overview: "", posterPath: nil)
        #expect(movie.displayOverview == "No overview available")
    }

    @Test("Poster URL is nil when path is missing or empty")
    func posterURLNilWhenPathMissingOrEmpty() {
        #expect(Movie(id: 1, title: "t", overview: "o", posterPath: nil).posterURL == nil)
        #expect(Movie(id: 1, title: "t", overview: "o", posterPath: "").posterURL == nil)
    }
}
