//
//  MovieCredits.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Foundation

// MARK: - Credits

struct MovieCreditsResponse: Codable {
    let cast: [MovieCastMember]
}

struct MovieCastMember: Identifiable, Equatable, Codable {
    let id: Int
    let name: String
    let character: String

    var displayName: String {
        name.isEmpty ? "Unknown" : name
    }

    var displayCharacter: String {
        character.isEmpty ? "Unknown Character" : character
    }
}
