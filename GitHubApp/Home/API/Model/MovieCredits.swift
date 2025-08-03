//
//  MovieCredits.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Foundation

// MARK: - Credits

/**
 * Response model for movie credits API calls.
 *
 * This structure represents the response format from The Movie Database API
 * when fetching cast and crew information for a specific movie.
 */
struct MovieCreditsResponse: Codable {
    /// Array of cast members for the movie
    let cast: [MovieCastMember]
}

/**
 * Model representing a single cast member in a movie.
 *
 * This model includes actor information and their character role,
 * with computed properties for safe display formatting.
 *
 * Conforms to:
 * - Identifiable: For SwiftUI list identification
 * - Equatable: For comparison operations
 * - Codable: For JSON serialization/deserialization
 */
struct MovieCastMember: Identifiable, Equatable, Codable {
    /// Unique cast member identifier from The Movie Database
    let id: Int

    /// Actor's real name
    let name: String

    /// Character name played by the actor
    let character: String

    /**
     * Computed property for display-safe actor name.
     *
     * Provides a fallback name for cast members that don't have a proper name,
     * ensuring the UI always has something to display.
     *
     * - Returns: Actor name or "Unknown" if name is empty
     */
    var displayName: String {
        name.isEmpty ? "Unknown" : name
    }

    /**
     * Computed property for display-safe character name.
     *
     * Provides a fallback character name for cast members that don't have
     * a proper character name, ensuring the UI always has something to display.
     *
     * - Returns: Character name or "Unknown Character" if character is empty
     */
    var displayCharacter: String {
        character.isEmpty ? "Unknown Character" : character
    }
}
