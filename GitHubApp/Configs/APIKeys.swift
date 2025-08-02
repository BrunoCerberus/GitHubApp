//
//  APIKeys.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Foundation

enum APIKeysProvider {
    static let theMovieAPIKey: String = {
        // Read API_KEY directly from environment variables set in schemes
        guard let apiKey = ProcessInfo.processInfo.environment["API_KEY"], !apiKey.isEmpty else {
            fatalError("API_KEY not found in environment variables. Make sure to run with the correct scheme (GitHubAppDev or GitHubAppProd)")
        }
        
        return apiKey
    }()
}
