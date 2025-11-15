//
//  MovieCreditsTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import Testing

@MainActor
struct MovieCreditsTests {
    @Test("Display name falls back to 'Unknown' when name is empty")
    func displayNameFallback() {
        let cast = MovieCastMember(id: 1, name: "", character: "Char")
        #expect(cast.displayName == "Unknown")
    }

    @Test("Display character falls back to 'Unknown Character' when character is empty")
    func displayCharacterFallback() {
        let cast = MovieCastMember(id: 1, name: "Name", character: "")
        #expect(cast.displayCharacter == "Unknown Character")
    }
}
