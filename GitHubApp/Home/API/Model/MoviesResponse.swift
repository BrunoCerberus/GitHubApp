//
//  MoviesResponse.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Foundation
import EntropyCore

// MARK: - Movies

struct MoviesResponse: Codable {
    let results: [Movie]
}

struct Movie: Codable, Hashable, Identifiable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    
    var posterURL: URL? {
        guard let posterPath = posterPath, !posterPath.isEmpty else { return nil }
        return URL(string: BaseURLs.image.rawValue + posterPath)
    }
    
    var displayTitle: String {
        return title.isEmpty ? "Untitled" : title
    }
    
    var displayOverview: String {
        return overview.isEmpty ? "No overview available" : overview
    }
}

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

// MARK: - Reviews

struct MovieReviewsResponse: Codable {
    let results: [MovieReview]
}

struct MovieReview: Identifiable, Equatable, Codable {
    let id: String
    let author: String
    let content: String
    
    var displayAuthor: String {
        return author.isEmpty ? "Anonymous" : author
    }
    
    var displayContent: String {
        return content.isEmpty ? "No review content available" : content
    }
}
