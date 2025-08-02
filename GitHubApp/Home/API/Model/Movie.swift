//
//  Movie.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import EntropyCore
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