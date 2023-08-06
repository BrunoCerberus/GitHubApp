//
//  HomeService.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Combine

protocol HomeServiceProtocol {
    func fetchMovies() -> AnyPublisher<MoviesResponse, Error>
}

final class HomeService: APIRequest, HomeServiceProtocol {
    func fetchMovies() -> AnyPublisher<MoviesResponse, Error> {
        self.fetchRequest(target: HomeAPI.fetchMovies, dataType: MoviesResponse.self)
            .eraseToAnyPublisher()
    }
}
