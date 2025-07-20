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
        guard var components = URLComponents(string: baseURL) else {
            fatalError("Invalid base URL: \(baseURL)")
        }
        
        var queryItems: [URLQueryItem] = []
        
        switch self {
        case .fetchMovies:
            components.path += "/movie/upcoming"
            
        case let .searchMovies(query):
            components.path += "/search/movie"
            queryItems.append(URLQueryItem(name: "query", value: query))
            
        case let .fetchCredits(id):
            components.path += "/movie/\(id)/credits"
            
        case let .fetchReviews(id):
            components.path += "/movie/\(id)/reviews"
        }

        // Add API key to all requests
        queryItems.append(URLQueryItem(name: "api_key", value: apiKey))
        components.queryItems = queryItems
        
        guard let urlString = components.string else {
            fatalError("Failed to construct URL from components")
        }
        
        return urlString
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
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
}
