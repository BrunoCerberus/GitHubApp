//
//  APIKeys.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Foundation

struct APIKeys {
    #if DEBUG
    static let theMovieAPIKey: String = {
        guard let path = Bundle.main.path(forResource: "Dev", ofType: "xcconfig"),
              let config = NSDictionary(contentsOfFile: path),
              let apiKey = config["API_KEY"] as? String else {
            fatalError("Unable to read development API key from configuration file.")
        }
        return apiKey
    }()
    #else
    static let theMovieAPIKey: String = {
        guard let path = Bundle.main.path(forResource: "Prod", ofType: "xcconfig"),
              let config = NSDictionary(contentsOfFile: path),
              let apiKey = config["API_KEY"] as? String else {
            fatalError("Unable to read production API key from configuration file.")
        }
        return apiKey
    }()
    #endif
}
