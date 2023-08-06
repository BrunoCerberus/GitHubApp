//
//  MoviesResponse.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Foundation

struct MoviesResponse: Codable {
    let results: [Movie]
}

// MARK: - Movies

struct Movie: Codable, Equatable, Identifiable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    var posterURL: URL? {
        posterPath.map { URL(string: "https://image.tmdb.org/t/p/w400/\($0)")! }
    }
}

//MARK: - Credits

struct MovieCastMember: Identifiable, Equatable, Decodable {
    let id: Int
    let name: String
    let character: String
}

struct MovieCreditsResponse: Decodable {
    let cast: [MovieCastMember]
}

//MARK: - Reviews

struct MovieReview: Identifiable, Equatable, Decodable {
    let id: String
    let author: String
    let content: String
}

struct MovieReviewsResponse: Decodable {
    let results: [MovieReview]
}
