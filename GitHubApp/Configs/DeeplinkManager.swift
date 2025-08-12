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

        // Check if this is our custom URL scheme
        guard components.scheme == "githubapp" else {
            return .unknown
        }

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

    /// Create a deeplink URL for movie details
    /// - Parameter movieId: The movie ID to create a deeplink for
    /// - Returns: A URL that can be used to deeplink to movie details
    func createMovieDetailsURL(movieId: Int) -> URL? {
        URL(string: URLScheme.movieDetails.scheme + "/\(movieId)")
    }

    /// Check if a URL is a valid deeplink for this app
    /// - Parameter url: The URL to check
    /// - Returns: True if the URL is a valid deeplink
    func isValidDeeplink(url: URL) -> Bool {
        parse(url: url) != .unknown
    }
}
