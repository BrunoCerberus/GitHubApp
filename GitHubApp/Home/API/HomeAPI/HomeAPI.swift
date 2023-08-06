//
//  HomeAPI.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Foundation

enum HomeAPI: APIFetcher {
    case fetchMovies
    
    var path: String {
        return ""
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
