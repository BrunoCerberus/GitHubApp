//
//  DeeplinkManager.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import Foundation
import UIKit

/**
 * Manages deeplinks and URL schemes for the app.
 *
 * This class handles parsing incoming URLs and converting them to
 * navigation events that can be processed by the app's routing system.
 */
final class DeeplinkManager {
    /// Supported URL schemes for the app
    enum URLScheme: String, CaseIterable {
        case movieDetails = "movie"

        var scheme: String {
            "githubapp://\(rawValue)"
        }

        var universalLink: String {
            "https://githubapp.com/\(rawValue)"
        }
    }

    /// Deeplink types that can be processed
    enum DeeplinkType: Equatable {
        case movieDetails(movieId: Int)
        case unknown
    }

    /// Parse a URL and return the corresponding deeplink type
    /// - Parameter url: The URL to parse
    /// - Returns: The parsed deeplink type
    func parse(url: URL) -> DeeplinkType {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return .unknown
        }

        // Handle custom URL scheme (githubapp://)
        if components.scheme == "githubapp" {
            return parseCustomScheme(components: components)
        }

        // Handle universal links (https://githubapp.com)
        if components.scheme == "https", components.host == "githubapp.com" {
            return parseUniversalLink(components: components)
        }

        return .unknown
    }

    /// Parse custom URL scheme (githubapp://)
    /// - Parameter components: The URL components to parse
    /// - Returns: The parsed deeplink type
    private func parseCustomScheme(components: URLComponents) -> DeeplinkType {
        // For URLs like githubapp://movie/123, the host is "movie" and path is "/123"
        guard let host = components.host else {
            return .unknown
        }

        switch host {
        case "movie":
            // Handle movie details deeplink: githubapp://movie/{id}
            let pathComponents = components.path.split(separator: "/").map(String.init).filter { !$0.isEmpty }
            if pathComponents.count >= 1,
               let movieId = Int(pathComponents[0])
            {
                return .movieDetails(movieId: movieId)
            }
            return .unknown

        default:
            return .unknown
        }
    }

    /// Parse universal link (https://githubapp.com)
    /// - Parameter components: The URL components to parse
    /// - Returns: The parsed deeplink type
    private func parseUniversalLink(components: URLComponents) -> DeeplinkType {
        // For URLs like https://githubapp.com/movie/123, the path is "/movie/123"
        let pathComponents = components.path.split(separator: "/").map(String.init).filter { !$0.isEmpty }

        guard pathComponents.count >= 2 else {
            return .unknown
        }

        let section = pathComponents[0]

        switch section {
        case "movie":
            // Handle movie details universal link: https://githubapp.com/movie/{id}
            if let movieId = Int(pathComponents[1]) {
                return .movieDetails(movieId: movieId)
            }
            return .unknown

        default:
            return .unknown
        }
    }

    /// Create a deeplink URL for movie details
    /// - Parameter movieId: The movie ID to create a deeplink for
    /// - Returns: A URL that can be used to deeplink to movie details
    func createMovieDetailsURL(movieId: Int) -> URL? {
        URL(string: URLScheme.movieDetails.scheme + "/\(movieId)")
    }

    /// Create a universal link URL for movie details
    /// - Parameter movieId: The movie ID to create a universal link for
    /// - Returns: A universal link URL that can be used to deeplink to movie details
    func createMovieDetailsUniversalURL(movieId: Int) -> URL? {
        URL(string: URLScheme.movieDetails.universalLink + "/\(movieId)")
    }

    /// Check if a URL is a valid deeplink for this app
    /// - Parameter url: The URL to check
    /// - Returns: True if the URL is a valid deeplink
    func isValidDeeplink(url: URL) -> Bool {
        parse(url: url) != .unknown
    }
}
