//
//  APIKeys.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Foundation

enum APIKeysProvider {
    static let theMovieAPIKey: String = {
        // First try to read API_KEY from environment variables (for XcodeGen schemes)
        if let apiKey = ProcessInfo.processInfo.environment["API_KEY"], !apiKey.isEmpty {
            return apiKey
        }

        // Fallback for SweetPad or other build systems that don't set environment variables
        // This is the same API key used in the schemes
        return "da9bc8815fb0fc31d5ef6b3da097a009"
    }()
}
