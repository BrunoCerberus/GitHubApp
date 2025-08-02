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
        return name.isEmpty ? "Unknown" : name
    }

    var displayCharacter: String {
        return character.isEmpty ? "Unknown Character" : character
    }
}
