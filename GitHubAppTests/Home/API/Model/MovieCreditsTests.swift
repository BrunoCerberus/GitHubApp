//
//  MovieCreditsTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import XCTest

final class MovieCreditsTests: XCTestCase {
    func testDisplayNameFallback() {
        let cast = MovieCastMember(id: 1, name: "", character: "Char")
        XCTAssertEqual(cast.displayName, "Unknown")
    }

    func testDisplayCharacterFallback() {
        let cast = MovieCastMember(id: 1, name: "Name", character: "")
        XCTAssertEqual(cast.displayCharacter, "Unknown Character")
    }
}
