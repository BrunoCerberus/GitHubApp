//
//  APIKeys.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Foundation

enum APIKeysProvider {
    static let theMovieAPIKey: String = {
        let environment = ProcessInfo.processInfo.environment["API_ENVIRONMENT"] ?? "Dev"

        guard let path = Bundle.main.path(
            forResource: environment,
            ofType: "xcconfig"
        ) else {
            fatalError("Unable to find configuration file for environment: \(environment)")
        }

        guard let config = NSDictionary(contentsOfFile: path) else {
            fatalError("Unable to read configuration file at path: \(path)")
        }

        guard let apiKey = config["API_KEY"] as? String, !apiKey.isEmpty else {
            fatalError("API_KEY not found or empty in configuration file for environment: \(environment)")
        }

        return apiKey
    }()
}
