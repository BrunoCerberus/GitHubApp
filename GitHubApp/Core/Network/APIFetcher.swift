//
//  APIFetcher.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Foundation

/// HTTP Methods
public enum HTTPMethod: String {
   case GET
   case POST
   case DELETE
   case PUT
}

protocol APIFetcher {
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String { get }

    /// The HTTP method used in the request.
    var method: HTTPMethod { get }

    /// The task to be used in the request.
    var task: Codable? { get }

    /// The request header key values
    var header: Codable? { get }

    /// For debug purposes
    var debug: Bool { get }
}
