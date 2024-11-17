//
//  HomeAPI.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Foundation
import EntropyCore

enum HomeAPI: APIFetcher {
    case fetchMovies
    case searchMovies(String)
    case fetchCredits(Int)
    case fetchReviews(Int)

    private var baseURL: String {
        return BaseURLs.theMovie.rawValue
    }

    private var apiKey: String {
        return APIKeysProvider.theMovieAPIKey
    }

    var path: String {
        var components = URLComponents(string: baseURL)!
        switch self {
        case .fetchMovies:
            components.path += "/movie/upcoming"
        case let .searchMovies(query):
            components.path += "/search/movie"
            components.queryItems = [URLQueryItem(name: "query", value: query)]
        case let .fetchCredits(id):
            components.path += "/movie/\(id)/credits"
        case let .fetchReviews(id):
            components.path += "/movie/\(id)/reviews"
        }

        components.queryItems = (components.queryItems ?? []) + [URLQueryItem(name: "api_key", value: apiKey)]
        return components.string ?? ""
    }

    var method: HTTPMethod {
        return .GET
    }

    var task: Codable? {
        return nil
    }

    var header: Codable? {
        return nil
    }

    var debug: Bool {
        return true
    }
}
