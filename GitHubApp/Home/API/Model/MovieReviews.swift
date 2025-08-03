//
//  MovieReviews.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Foundation

// MARK: - Reviews

struct MovieReviewsResponse: Codable {
    let results: [MovieReview]
}

struct MovieReview: Identifiable, Equatable, Codable {
    let id: String
    let author: String
    let content: String

    var displayAuthor: String {
        author.isEmpty ? "Anonymous" : author
    }

    var displayContent: String {
        content.isEmpty ? "No review content available" : content
    }
}
