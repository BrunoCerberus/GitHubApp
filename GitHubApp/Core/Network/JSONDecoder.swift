//
//  JSONDecoder.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Foundation

let jsonDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
}()
