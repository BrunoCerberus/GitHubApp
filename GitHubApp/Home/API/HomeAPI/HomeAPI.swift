//
//  HomeAPI.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Foundation

enum HomeAPI: APIFetcher {
    case fetchMovies
    case searchMovies(String)
    case fetchCredits(Int)
    case fetchReviews(Int)
    
    var path: String {
        switch self {
        case .fetchMovies:
            return BaseURLs.theMovie.rawValue + "/movie/upcoming?api_key=\(APIKeys.theMovieAPIKey)"
        case let .searchMovies(query):
            return BaseURLs.theMovie.rawValue + "/search/movie?api_key=\(APIKeys.theMovieAPIKey)&query=\(query)"
        case let .fetchCredits(id):
            return BaseURLs.theMovie.rawValue + "/movie/\(id)/credits?api_key=\(APIKeys.theMovieAPIKey)"
        case let .fetchReviews(id):
            return BaseURLs.theMovie.rawValue + "/movie/\(id)/reviews?api_key=\(APIKeys.theMovieAPIKey)"
        }
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
    
}
