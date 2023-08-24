//
//  MoviesResponse.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Foundation

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
        posterPath.flatMap { URL(string: "https://image.tmdb.org/t/p/w400/\($0)") }
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
}

// MARK: - Reviews

struct MovieReviewsResponse: Codable {
    let results: [MovieReview]
}

struct MovieReview: Identifiable, Equatable, Codable {
    let id: String
    let author: String
    let content: String
}
